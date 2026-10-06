import { createPrivateKey, createSign } from 'crypto';

type GoogleAccessTokenCache = {
  token: string;
  expiresAtMs: number;
};

let cachedToken: GoogleAccessTokenCache | null = null;

type ServiceAccount = {
  client_email: string;
  private_key: string;
};

function readServiceAccount(): ServiceAccount | null {
  const raw = (process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON || '').trim();
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw) as ServiceAccount;
    if (!parsed.client_email || !parsed.private_key) return null;
    return parsed;
  } catch {
    return null;
  }
}

function base64Url(input: Buffer | string): string {
  const buf = typeof input === 'string' ? Buffer.from(input) : input;
  return buf
    .toString('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

async function getAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Date.now();
  if (cachedToken && cachedToken.expiresAtMs > now + 60_000) {
    return cachedToken.token;
  }

  const iat = Math.floor(now / 1000);
  const header = base64Url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const claim = base64Url(
    JSON.stringify({
      iss: sa.client_email,
      scope: 'https://www.googleapis.com/auth/androidpublisher',
      aud: 'https://oauth2.googleapis.com/token',
      iat,
      exp: iat + 3600,
    })
  );
  const unsigned = `${header}.${claim}`;
  const key = createPrivateKey(sa.private_key);
  const signer = createSign('RSA-SHA256');
  signer.update(unsigned);
  signer.end();
  const signature = base64Url(signer.sign(key));
  const assertion = `${unsigned}.${signature}`;

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Google OAuth token exchange failed (${res.status}): ${body.slice(0, 200)}`);
  }
  const json = (await res.json()) as { access_token?: string; expires_in?: number };
  if (!json.access_token) {
    throw new Error('Google OAuth response missing access_token');
  }
  cachedToken = {
    token: json.access_token,
    expiresAtMs: now + (json.expires_in ?? 3600) * 1000,
  };
  return json.access_token;
}

export type GooglePlayPurchase = {
  productId: string;
  purchaseToken: string;
  orderId: string;
  purchaseState: number;
  consumptionState: number;
  acknowledged: boolean;
  raw: unknown;
};

/**
 * Confirms a Google Play consumable purchase via the Android Publisher API.
 * purchaseState 0 = purchased. consumptionState 1 = already consumed.
 */
export async function verifyGooglePlayPurchase(input: {
  productId: string;
  purchaseToken: string;
}): Promise<GooglePlayPurchase> {
  const sa = readServiceAccount();
  if (!sa) {
    throw new Error('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is not configured');
  }
  const packageName =
    (process.env.GOOGLE_PLAY_PACKAGE_NAME || '').trim() || 'eu.thefit.celia';
  const token = await getAccessToken(sa);
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/` +
    `${encodeURIComponent(packageName)}/purchases/products/` +
    `${encodeURIComponent(input.productId)}/tokens/` +
    `${encodeURIComponent(input.purchaseToken)}`;

  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const text = await res.text();
  let json: Record<string, unknown> = {};
  try {
    json = text ? (JSON.parse(text) as Record<string, unknown>) : {};
  } catch {
    json = { raw: text };
  }
  if (!res.ok) {
    throw new Error(
      `Google Play verify failed (${res.status}): ${text.slice(0, 300)}`
    );
  }

  const purchaseState = Number(json.purchaseState ?? -1);
  if (purchaseState !== 0) {
    throw new Error(`Google Play purchase is not in purchased state (${purchaseState})`);
  }

  const orderId =
    typeof json.orderId === 'string' && json.orderId
      ? json.orderId
      : input.purchaseToken;

  return {
    productId: input.productId,
    purchaseToken: input.purchaseToken,
    orderId,
    purchaseState,
    consumptionState: Number(json.consumptionState ?? 0),
    acknowledged: Boolean(json.acknowledgementState),
    raw: json,
  };
}
