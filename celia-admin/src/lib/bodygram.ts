/**
 * Bodygram Platform client.
 *
 * Server-side only: the organisation API key can create and read scans for the
 * whole org and spend our quota, so it must never reach a device. The mobile
 * app talks to /api/mobile/body-scan, and this module is the only thing that
 * talks to Bodygram.
 */

const DEFAULT_BASE_URL = 'https://platform.bodygram.com';

export type BodygramGender = 'male' | 'female';

export type BodygramScanInput = {
  age: number;
  gender: BodygramGender;
  /** Millimetres, 500–2500. */
  heightMm: number;
  /** Grams, 10000–200000. */
  weightG: number;
  /** Raw base64 JPEG, front-facing. No data: prefix. */
  frontPhotoBase64: string;
  /** Raw base64 JPEG, right side. No data: prefix. */
  rightPhotoBase64: string;
  /** Our own id for the scan row, echoed back by the vendor. */
  customScanId?: string;
};

export type BodygramMeasurement = {
  name: string;
  unit: string;
  value: number;
};

type Quantity = { unit: string; value: number };

export type BodygramEntry = {
  id: string;
  status: 'success' | 'failure';
  measurements?: BodygramMeasurement[] | null;
  avatar?: { data: string; format: string; type: string } | null;
  bodyComposition?: {
    bodyFatPercentage?: Quantity;
    bodyFatMass?: Quantity;
    leanMass?: Quantity;
  } | null;
  posture?: unknown;
  error?: { code: string } | null;
};

/**
 * A scan the vendor accepted but could not produce a result for — nearly
 * always the photos. Distinct from a transport failure because the user can
 * fix it by retaking, so the app shows guidance rather than an error.
 */
export class BodygramScanFailure extends Error {
  constructor(
    readonly code: string,
    readonly category: BodygramFailureCategory
  ) {
    super(`Bodygram scan failed: ${code}`);
  }
}

/** The vendor was unreachable, rejected our credentials, or is out of quota. */
export class BodygramRequestError extends Error {
  constructor(
    readonly status: number,
    readonly body: string
  ) {
    super(`Bodygram request failed (${status})`);
  }
}

export type BodygramFailureCategory =
  | 'framing'
  | 'quality'
  | 'pose'
  | 'clothing'
  | 'unknown';

/**
 * Buckets a vendor error code so the app can show one piece of retake advice
 * per category instead of translating every individual code into 18 languages.
 * Codes look like `rightPhotoFacingWrongDirection`.
 */
export function categorizeFailure(code: string): BodygramFailureCategory {
  const lower = code.toLowerCase();
  if (/(direction|facing|pose|posing|arm|leg|stance)/.test(lower)) return 'pose';
  if (/(crop|frame|framing|cut|partial|distance|missing|notfound|person|face)/.test(lower))
    return 'framing';
  if (/(blur|dark|light|exposure|resolution|quality|noise|format)/.test(lower))
    return 'quality';
  if (/(cloth|loose|baggy|garment)/.test(lower)) return 'clothing';
  return 'unknown';
}

function requireConfig() {
  const orgId = process.env.BODYGRAM_ORG_ID;
  const apiKey = process.env.BODYGRAM_API_KEY;
  if (!orgId) throw new Error('Missing BODYGRAM_ORG_ID');
  if (!apiKey) throw new Error('Missing BODYGRAM_API_KEY');
  return {
    orgId,
    apiKey,
    baseUrl: process.env.BODYGRAM_BASE_URL || DEFAULT_BASE_URL,
  };
}

export function isBodygramConfigured(): boolean {
  return Boolean(process.env.BODYGRAM_ORG_ID && process.env.BODYGRAM_API_KEY);
}

/** Bodygram rejects data URLs; it wants the raw RFC 4648 encoding. */
function stripDataUrl(base64: string): string {
  return base64.replace(/^data:image\/\w+;base64,/, '').trim();
}

export async function createPhotoScan(input: BodygramScanInput): Promise<BodygramEntry> {
  const { orgId, apiKey, baseUrl } = requireConfig();

  const response = await fetch(`${baseUrl}/api/orgs/${orgId}/scans`, {
    method: 'POST',
    headers: {
      // The key is the header value itself — no Bearer prefix.
      Authorization: apiKey,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      ...(input.customScanId ? { customScanId: input.customScanId } : {}),
      photoScan: {
        age: Math.round(input.age),
        gender: input.gender,
        height: Math.round(input.heightMm),
        weight: Math.round(input.weightG),
        frontPhoto: stripDataUrl(input.frontPhotoBase64),
        rightPhoto: stripDataUrl(input.rightPhotoBase64),
      },
    }),
  });

  if (!response.ok) {
    throw new BodygramRequestError(response.status, (await response.text()).slice(0, 500));
  }

  const entry = ((await response.json()) as { entry?: BodygramEntry }).entry;
  if (!entry) throw new BodygramRequestError(response.status, 'Response had no entry');

  // A failed scan still comes back as HTTP 200, so status is the only signal.
  if (entry.status === 'failure') {
    const code = entry.error?.code || 'unknown';
    throw new BodygramScanFailure(code, categorizeFailure(code));
  }

  return entry;
}
