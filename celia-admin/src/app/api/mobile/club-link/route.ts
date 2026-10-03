import { NextResponse } from 'next/server';

export const runtime = 'nodejs';

// The club's own app is provisional, so the link is served from here and can be
// swapped or switched off without shipping a new build of Celia. Set
// CLUB_APP_URL to change it and CLUB_APP_ENABLED=false to hide it.
const DEFAULT_CLUB_URL = 'https://preview.builtwithrocket.new/thefitclub-0ewx?p=c';

function configuredUrl(): string {
  const candidate = (process.env.CLUB_APP_URL || '').trim() || DEFAULT_CLUB_URL;
  try {
    const parsed = new URL(candidate);
    return parsed.protocol === 'https:' ? parsed.toString() : DEFAULT_CLUB_URL;
  } catch {
    return DEFAULT_CLUB_URL;
  }
}

export async function GET() {
  const enabled = (process.env.CLUB_APP_ENABLED || 'true').trim().toLowerCase() !== 'false';
  return NextResponse.json(
    { enabled, url: configuredUrl() },
    { headers: { 'Cache-Control': 'public, max-age=300' } }
  );
}
