import { X509Certificate } from 'crypto';
import { importPKCS8, importX509, jwtVerify, SignJWT } from 'jose';

export type AppleTransaction = {
  productId: string;
  transactionId: string;
  originalTransactionId: string;
  bundleId: string;
  environment: string;
  raw: unknown;
};

function expectedBundleId(): string {
  return (process.env.APPLE_BUNDLE_ID || '').trim() || 'eu.thefit.celia';
}

/**
 * Verifies an App Store purchase.
 * Prefers App Store Server API when APPLE_IAP_* credentials are set.
 * Otherwise validates a StoreKit 2 signed-transaction JWS via its x5c chain,
 * or falls back to the legacy verifyReceipt endpoint.
 */
export async function verifyAppleTransaction(input: {
  productId: string;
  signedTransaction: string;
}): Promise<AppleTransaction> {
  const raw = input.signedTransaction.trim();
  if (!raw) throw new Error('Apple verification data is empty');

  if (raw.split('.').length === 3) {
    const fromApi = await tryAppStoreServerApi(raw);
    if (fromApi) {
      assertMatchesProduct(fromApi, input.productId);
      return fromApi;
    }
    const local = await verifyAppleJwsLocally(raw);
    assertMatchesProduct(local, input.productId);
    return local;
  }

  const legacy = await verifyAppleLegacyReceipt({
    productId: input.productId,
    receiptData: raw,
  });
  assertMatchesProduct(legacy, input.productId);
  return legacy;
}

function assertMatchesProduct(tx: AppleTransaction, productId: string): void {
  if (tx.productId !== productId) {
    throw new Error(
      `Apple product mismatch: expected ${productId}, got ${tx.productId}`
    );
  }
  if (tx.bundleId !== expectedBundleId()) {
    throw new Error(`Apple bundle mismatch: ${tx.bundleId}`);
  }
}

async function tryAppStoreServerApi(
  signedTransaction: string
): Promise<AppleTransaction | null> {
  const keyId = (process.env.APPLE_IAP_KEY_ID || '').trim();
  const issuerId = (process.env.APPLE_IAP_ISSUER_ID || '').trim();
  const privateKeyPem = (process.env.APPLE_IAP_PRIVATE_KEY || '')
    .trim()
    .replace(/\\n/g, '\n');
  if (!keyId || !issuerId || !privateKeyPem) return null;

  const payload = decodePayload(signedTransaction);
  const transactionId =
    typeof payload.transactionId === 'string' ? payload.transactionId : '';
  if (!transactionId) return null;

  const key = await importPKCS8(privateKeyPem, 'ES256');
  const token = await new SignJWT({})
    .setProtectedHeader({ alg: 'ES256', kid: keyId, typ: 'JWT' })
    .setIssuer(issuerId)
    .setIssuedAt()
    .setExpirationTime('20m')
    .setAudience('appstoreconnect-v1')
    .setSubject(expectedBundleId())
    .sign(key);

  const envHint = (process.env.APPLE_IAP_ENVIRONMENT || '').trim().toLowerCase();
  const hosts =
    envHint === 'sandbox'
      ? ['https://api.storekit-sandbox.itunes.apple.com']
      : envHint === 'production'
        ? ['https://api.storekit.itunes.apple.com']
        : [
            'https://api.storekit.itunes.apple.com',
            'https://api.storekit-sandbox.itunes.apple.com',
          ];

  let lastError = '';
  for (const host of hosts) {
    const res = await fetch(
      `${host}/inApps/v1/transactions/${encodeURIComponent(transactionId)}`,
      { headers: { Authorization: `Bearer ${token}` } }
    );
    if (res.status === 404) {
      lastError = '404';
      continue;
    }
    if (!res.ok) {
      lastError = `${res.status} ${(await res.text()).slice(0, 160)}`;
      continue;
    }
    const json = (await res.json()) as { signedTransactionInfo?: string };
    if (!json.signedTransactionInfo) {
      lastError = 'missing signedTransactionInfo';
      continue;
    }
    return decodeAppleTransactionPayload(json.signedTransactionInfo);
  }
  throw new Error(`Apple App Store Server API failed: ${lastError}`);
}

// SHA-256 fingerprint of "Apple Root CA - G3", the root of every StoreKit 2
// signed transaction. The chain in the JWS header must end at exactly this
// certificate, otherwise anyone could sign a forged transaction themselves.
const APPLE_ROOT_CA_G3_SHA256 =
  '63343abfb89a6a03ebb57e9b3f5fa7be7c4f5c756f3017b3a8c488c3653e9179';

async function verifyAppleJwsLocally(jws: string): Promise<AppleTransaction> {
  const header = JSON.parse(
    Buffer.from(jws.split('.')[0]!, 'base64url').toString('utf8')
  ) as { x5c?: string[] };
  const x5c = header.x5c;
  if (!x5c || x5c.length < 2) {
    throw new Error('Apple JWS missing x5c certificate chain');
  }

  const certs = x5c.map((der) => new X509Certificate(Buffer.from(der, 'base64')));

  const now = Date.now();
  for (const cert of certs) {
    if (now < Date.parse(cert.validFrom) || now > Date.parse(cert.validTo)) {
      throw new Error('Apple JWS certificate is outside its validity period');
    }
  }

  // Each certificate must be signed by the next one up the chain.
  for (let i = 0; i < certs.length - 1; i++) {
    if (!certs[i]!.verify(certs[i + 1]!.publicKey)) {
      throw new Error('Apple JWS certificate chain is not valid');
    }
  }

  const root = certs[certs.length - 1]!;
  const rootFingerprint = root.fingerprint256.replace(/:/g, '').toLowerCase();
  if (rootFingerprint !== APPLE_ROOT_CA_G3_SHA256) {
    throw new Error('Apple JWS is not rooted in Apple Root CA - G3');
  }

  const key = await importX509(derToPem(x5c[0]!), 'ES256');
  await jwtVerify(jws, key, { algorithms: ['ES256'] });

  return decodeAppleTransactionPayload(jws);
}

function decodePayload(jws: string): Record<string, unknown> {
  const part = jws.split('.')[1];
  if (!part) throw new Error('Apple JWS missing payload');
  return JSON.parse(Buffer.from(part, 'base64url').toString('utf8')) as Record<
    string,
    unknown
  >;
}

function decodeAppleTransactionPayload(jws: string): AppleTransaction {
  const payload = decodePayload(jws);
  const productId = String(payload.productId || '');
  const transactionId = String(payload.transactionId || '');
  const originalTransactionId = String(
    payload.originalTransactionId || transactionId
  );
  const bundleId = String(payload.bundleId || '');
  const environment = String(payload.environment || '');

  if (!productId || !transactionId || !bundleId) {
    throw new Error('Apple transaction payload incomplete');
  }
  if (payload.revocationDate) {
    throw new Error('Apple transaction was revoked');
  }

  return {
    productId,
    transactionId,
    originalTransactionId,
    bundleId,
    environment,
    raw: payload,
  };
}

function derToPem(derB64: string): string {
  const lines = derB64.match(/.{1,64}/g) ?? [derB64];
  return `-----BEGIN CERTIFICATE-----\n${lines.join('\n')}\n-----END CERTIFICATE-----\n`;
}

async function verifyAppleLegacyReceipt(input: {
  productId: string;
  receiptData: string;
}): Promise<AppleTransaction> {
  const sharedSecret = (process.env.APPLE_IAP_SHARED_SECRET || '').trim();
  if (!sharedSecret) {
    throw new Error(
      'Apple receipt is not a JWS and APPLE_IAP_SHARED_SECRET is not configured'
    );
  }

  const body = {
    'receipt-data': input.receiptData,
    password: sharedSecret,
    'exclude-old-transactions': true,
  };

  const endpoints = [
    'https://buy.itunes.apple.com/verifyReceipt',
    'https://sandbox.itunes.apple.com/verifyReceipt',
  ];

  let json: Record<string, unknown> | null = null;
  for (const url of endpoints) {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    json = (await res.json()) as Record<string, unknown>;
    if (Number(json.status) === 21007) continue;
    break;
  }
  if (!json) throw new Error('Apple verifyReceipt returned no body');
  if (Number(json.status) !== 0) {
    throw new Error(`Apple verifyReceipt status ${json.status}`);
  }

  const receipt = json.receipt as Record<string, unknown> | undefined;
  const inApp =
    (receipt?.in_app as Array<Record<string, unknown>> | undefined) ?? [];
  const latest =
    inApp
      .filter((item) => String(item.product_id) === input.productId)
      .sort(
        (a, b) =>
          Number(b.purchase_date_ms || 0) - Number(a.purchase_date_ms || 0)
      )[0] ?? null;

  if (!latest) {
    throw new Error(`Apple receipt has no purchase for ${input.productId}`);
  }

  const transactionId = String(latest.transaction_id || '');
  if (!transactionId) throw new Error('Apple receipt missing transaction_id');

  return {
    productId: input.productId,
    transactionId,
    originalTransactionId: String(
      latest.original_transaction_id || transactionId
    ),
    bundleId: String(receipt?.bundle_id || expectedBundleId()),
    environment: 'LegacyReceipt',
    raw: latest,
  };
}
