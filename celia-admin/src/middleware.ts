import { NextResponse, type NextRequest } from 'next/server';

function unauthorized() {
  return new NextResponse('Unauthorized', {
    status: 401,
    headers: {
      'WWW-Authenticate': 'Basic realm="Celia Admin"',
    },
  });
}

export function middleware(req: NextRequest) {
  // Mobile app endpoints must not be behind dashboard Basic Auth.
  // They have their own auth (Firebase ID token verification) in the route handler.
  if (req.nextUrl.pathname.startsWith('/api/mobile/')) {
    return NextResponse.next();
  }

  const user = process.env.ADMIN_BASIC_AUTH_USER;
  const pass = process.env.ADMIN_BASIC_AUTH_PASS;

  // If not configured, do not block (dev / local).
  if (!user || !pass) return NextResponse.next();

  const auth = req.headers.get('authorization') || '';
  const [scheme, encoded] = auth.split(' ');
  if (scheme !== 'Basic' || !encoded) return unauthorized();

  try {
    const decoded = Buffer.from(encoded, 'base64').toString('utf8');
    const idx = decoded.indexOf(':');
    if (idx < 0) return unauthorized();
    const u = decoded.slice(0, idx);
    const p = decoded.slice(idx + 1);
    if (u !== user || p !== pass) return unauthorized();
    return NextResponse.next();
  } catch {
    return unauthorized();
  }
}

export const config = {
  matcher: [
    /**
     * Protect everything except Next.js internals and static assets.
     */
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
};


