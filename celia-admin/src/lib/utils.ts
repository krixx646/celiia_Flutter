import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function cloudflareThumbnailUrl(cloudflareVideoId: string): string {
  // Works for Cloudflare Stream assets by uid, no account id required.
  return `https://videodelivery.net/${cloudflareVideoId}/thumbnails/thumbnail.jpg`;
}

export function resolveThumbnailUrl(opts: {
  thumbnail_url?: string | null;
  cloudflare_video_id?: string | null;
  playback_url?: string | null;
}): string | null {
  if (opts.thumbnail_url && opts.thumbnail_url.trim().length > 0) return opts.thumbnail_url;
  const cfId = (opts.cloudflare_video_id || '').trim();
  if (!cfId || cfId.startsWith('fal-')) return null;
  return cloudflareThumbnailUrl(cfId);
}

export function tryExtractCloudflareIdFromUrl(url: string): string | null {
  // Examples:
  // - https://iframe.videodelivery.net/<uid>
  // - https://videodelivery.net/<uid>/manifest/video.m3u8
  // - https://customer-<account>.cloudflarestream.com/<uid>/manifest/video.m3u8
  const u = (url || '').trim();
  if (!u) return null;
  const m1 = u.match(/videodelivery\.net\/([^/?#]+)/i);
  if (m1?.[1]) return m1[1];
  const m2 = u.match(/cloudflarestream\.com\/([^/?#]+)/i);
  if (m2?.[1]) return m2[1];
  return null;
}

export function resolveAnyVideoThumbnailUrl(opts: {
  thumbnail_url?: string | null;
  cloudflare_video_id?: string | null;
  playback_url?: string | null;
}): string | null {
  const direct = resolveThumbnailUrl(opts);
  if (direct) return direct;
  const fromPlayback = opts.playback_url ? tryExtractCloudflareIdFromUrl(opts.playback_url) : null;
  if (fromPlayback) return cloudflareThumbnailUrl(fromPlayback);
  return null;
}

export function formatDuration(seconds: number): string {
  if (!Number.isFinite(seconds) || seconds <= 0) return '0:00';
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

export function formatDate(dateString?: string | null): string {
  if (!dateString) return '—';
  const date = new Date(dateString);
  if (Number.isNaN(date.getTime())) return '—';
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
}

