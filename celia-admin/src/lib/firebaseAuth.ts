import { createRemoteJWKSet, jwtVerify } from 'jose';

// Google's public keys for Firebase ID tokens. createRemoteJWKSet caches and
// refreshes them, so this must stay module-level rather than per-request.
const FIREBASE_JWKS = createRemoteJWKSet(
  new URL(
    'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com'
  )
);

export type VerifiedUser = { uid: string };

/**
 * Verifies the `Authorization: Bearer <Firebase ID token>` header sent by the
 * mobile app and returns the caller's Firebase uid, or null if the request is
 * not authenticated.
 *
 * The uid returned here is the only trustworthy identity in a request: never
 * take a user id from the request body, since a caller could put anyone's id
 * there.
 */
export async function verifyFirebaseUser(
  req: Request
): Promise<VerifiedUser | null> {
  const projectId = process.env.FIREBASE_PROJECT_ID;
  if (!projectId) return null;

  const auth = req.headers.get('authorization') || '';
  const [scheme, token] = auth.split(' ');
  if (scheme !== 'Bearer' || !token) return null;

  try {
    const { payload } = await jwtVerify(token, FIREBASE_JWKS, {
      issuer: `https://securetoken.google.com/${projectId}`,
      audience: projectId,
    });
    const uid = typeof payload.sub === 'string' ? payload.sub : '';
    if (!uid) return null;
    return { uid };
  } catch {
    return null;
  }
}
