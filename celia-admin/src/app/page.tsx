'use client';

import { useState, useEffect, useRef } from 'react';
import { Video, ListVideo, Trash2 } from 'lucide-react';
import Header from '@/components/Header';
import VideoCard from '@/components/VideoCard';
import UploadPanel from '@/components/UploadPanel';
import { supabase, Video as VideoType } from '@/lib/supabase';

const categories = ['All Videos', 'Yoga', 'HIIT', 'Strength', 'Cardio', 'Pilates', 'Drafts'];

function errorMessage(e: unknown): string {
  return e instanceof Error ? e.message : String(e);
}

export default function VideosPage() {
  const [videos, setVideos] = useState<VideoType[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState('All Videos');
  const [showUploadPanel, setShowUploadPanel] = useState(false);
  const [activeVideo, setActiveVideo] = useState<VideoType | null>(null);
  const [ingestingActiveVideo, setIngestingActiveVideo] = useState(false);
  const [ingestError, setIngestError] = useState<string | null>(null);
  const [deleteError, setDeleteError] = useState<string | null>(null);
  const [deletingVideoId, setDeletingVideoId] = useState<string | null>(null);
  const [cloudflareStatusText, setCloudflareStatusText] = useState<string | null>(null);
  const autoIngestAttemptedRef = useRef<Set<string>>(new Set());
  const autoIngestInProgressRef = useRef(false);
  const refreshAttemptedRef = useRef<Set<string>>(new Set());
  const [stats, setStats] = useState({
    totalVideos: 0,
    totalRoutines: 0,
  });

  useEffect(() => {
    loadVideos();
    loadStats();
  }, [selectedCategory]);

  useEffect(() => {
    // Background repair: ingest legacy AI videos (fal mp4) into Cloudflare so thumbnails + playback work without clicking each one.
    if (loading) return;
    if (autoIngestInProgressRef.current) return;
    if (videos.length === 0) return;

    const targets = videos
      .filter((v) => {
        const playback = (v.playback_url || '').trim();
        const source = (v.source_url || '').trim();
        const backupPath = (v.backup_path || '').trim();
        const playbackIsCloudflare = /cloudflarestream\.com|videodelivery\.net/i.test(playback);
        const sourceIsCloudflare = /cloudflarestream\.com|videodelivery\.net/i.test(source);
        const hasRecoverableSource =
          Boolean(backupPath) ||
          Boolean(source && !sourceIsCloudflare) ||
          Boolean(playback && !playbackIsCloudflare);
        if (!hasRecoverableSource) return false;

        const cfId = (v.cloudflare_video_id || '').trim();
        const hasCloudflare = cfId.length > 0 && !cfId.startsWith('fal-');
        const status = (v.status || '').toString().toLowerCase();
        // Recover legacy/stale rows when we still have a non-Cloudflare source URL.
        return !hasCloudflare || status === 'error';
      })
      .filter((v) => !autoIngestAttemptedRef.current.has(v.id))
      .slice(0, 3);

    if (targets.length === 0) return;

    autoIngestInProgressRef.current = true;
    (async () => {
      try {
        for (const v of targets) {
          autoIngestAttemptedRef.current.add(v.id);
          try {
            await fetch(`/api/admin/videos/${v.id}/ingest`, { method: 'POST' });
          } catch {
            // Ignore: user can still click a card to see the error + retry path.
          }
        }
      } finally {
        autoIngestInProgressRef.current = false;
      }

      // Refresh grid to show new thumbnails as they become available.
      await loadVideos();
    })();
  }, [loading, videos]);

  useEffect(() => {
    // Background repair: update Cloudflare metadata (status/duration/playback url) so UI doesn't show weird values like -1:-1.
    if (loading) return;
    if (videos.length === 0) return;

    const targets = videos
      .filter((v) => {
        const hasCf = Boolean((v.cloudflare_video_id || '').trim());
        if (!hasCf) return false;
        const dur = Number(v.duration_seconds);
        const durBad = !Number.isFinite(dur) || dur <= 0;
        const st = (v.status || '').toString().toLowerCase();
        const statusBad = st === 'processing' || st === 'pending';
        const playbackBad = !v.playback_url;
        return durBad || statusBad || playbackBad;
      })
      .filter((v) => !refreshAttemptedRef.current.has(v.id))
      .slice(0, 3);

    if (targets.length === 0) return;

    (async () => {
      for (const v of targets) {
        refreshAttemptedRef.current.add(v.id);
        try {
          await fetch(`/api/admin/videos/${v.id}/refresh`, { method: 'POST' });
        } catch {
          // ignore
        }
      }
      await loadVideos();
    })();
  }, [loading, videos]);

  useEffect(() => {
    // Auto-ingest legacy (non-Cloudflare) videos so playback + thumbnails behave consistently.
    let cancelled = false;
    async function maybeIngest() {
      if (!activeVideo) return;
      const playback = (activeVideo.playback_url || '').trim();
      const source = (activeVideo.source_url || '').trim();
      const backupPath = (activeVideo.backup_path || '').trim();
      const playbackIsCloudflare = /cloudflarestream\.com|videodelivery\.net/i.test(playback);
      const sourceIsCloudflare = /cloudflarestream\.com|videodelivery\.net/i.test(source);
      const hasRecoverableSource =
        Boolean(backupPath) ||
        Boolean(source && !sourceIsCloudflare) ||
        Boolean(playback && !playbackIsCloudflare);
      if (!hasRecoverableSource) return;

      const cfIdRaw = (activeVideo.cloudflare_video_id || '').trim();
      // Even if a Cloudflare UID exists, it may be stale; ingest route now validates and repairs.
      if (cfIdRaw.startsWith('fal-')) return;

      setIngestError(null);
      setCloudflareStatusText(null);
      setIngestingActiveVideo(true);
      try {
        const res = await fetch(`/api/admin/videos/${activeVideo.id}/ingest`, { method: 'POST' });
        const json = await res.json();
        if (!res.ok) throw new Error(json.error || 'Failed to ingest video');
        if (cancelled) return;
        if (json.video) setActiveVideo(json.video);
        // Refresh grid so thumbnails update right away.
        await loadVideos();
      } catch (e: unknown) {
        if (cancelled) return;
        setIngestError(errorMessage(e));
      } finally {
        if (!cancelled) setIngestingActiveVideo(false);
      }
    }
    maybeIngest();
    return () => {
      cancelled = true;
    };
  }, [activeVideo?.id]);

  useEffect(() => {
    // Always refresh Cloudflare metadata once when opening a selected Cloudflare-backed video.
    // This catches stale rows marked "ready" whose Stream asset no longer exists.
    let cancelled = false;
    async function maybeRefresh() {
      if (!activeVideo) return;
      const hasCf = Boolean((activeVideo.cloudflare_video_id || '').trim());
      if (!hasCf) return;

      try {
        const res = await fetch(`/api/admin/videos/${activeVideo.id}/refresh`, { method: 'POST' });
        const json = await res.json().catch(() => ({}));
        if (!res.ok) {
          if (cancelled) return;
          if (json?.video) setActiveVideo(json.video);
          const details = json?.details || json?.error || 'Cloudflare refresh failed';
          setCloudflareStatusText(String(details));
          await loadVideos();
          return;
        }
        if (cancelled) return;
        if (json.video) setActiveVideo(json.video);
        const cfState = json.cloudflare?.status?.state;
        const cfCode =
          json.cloudflare?.status?.errorReasonCode ||
          json.cloudflare?.status?.error_code ||
          json.cloudflare?.status?.code ||
          null;
        const cfMsg =
          json.cloudflare?.status?.errorReasonText ||
          json.cloudflare?.status?.errorReason ||
          json.cloudflare?.status?.message ||
          json.cloudflare?.status?.error ||
          null;
        if (cfState) {
          setCloudflareStatusText(
            cfCode && cfMsg
              ? `Cloudflare status: ${cfState} — ${cfCode}: ${cfMsg}`
              : cfMsg
                ? `Cloudflare status: ${cfState} — ${cfMsg}`
                : `Cloudflare status: ${cfState}`
          );
        } else {
          setCloudflareStatusText(null);
        }
        await loadVideos();
      } catch {
        // ignore
      }
    }
    maybeRefresh();
    return () => {
      cancelled = true;
    };
  }, [activeVideo?.id, activeVideo?.status]);

  async function loadVideos() {
    setLoading(true);
    try {
      let query = supabase.from('videos').select('*');
      
      if (selectedCategory !== 'All Videos' && selectedCategory !== 'Drafts') {
        query = query.eq('category', selectedCategory.toLowerCase());
      }
      
      if (selectedCategory === 'Drafts') {
        query = query.eq('status', 'pending');
      }

      const { data, error } = await query.order('uploaded_at', { ascending: false });
      
      if (error) throw error;
      setVideos(data || []);
    } catch (error) {
      console.error('Error loading videos:', error);
    } finally {
      setLoading(false);
    }
  }

  async function loadStats() {
    try {
      const [videosRes, routinesRes] = await Promise.all([
        supabase.from('videos').select('id', { count: 'exact' }),
        supabase.from('routines').select('id', { count: 'exact' }),
      ]);

      setStats({
        totalVideos: videosRes.count || 0,
        totalRoutines: routinesRes.count || 0,
      });
    } catch (error) {
      console.error('Error loading stats:', error);
    }
  }

  async function deleteVideo(video: VideoType) {
    if (!confirm(`Delete clip "${video.title}"?\n\nThis cannot be undone.`)) return;
    setDeleteError(null);
    setDeletingVideoId(video.id);
    try {
      const res = await fetch(`/api/admin/videos/${video.id}`, { method: 'DELETE' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to delete clip');

      setVideos((prev) => prev.filter((v) => v.id !== video.id));
      if (activeVideo?.id === video.id) setActiveVideo(null);
      await loadStats();
    } catch (e: unknown) {
      setDeleteError(errorMessage(e));
    } finally {
      setDeletingVideoId(null);
    }
  }

  return (
    <div className="min-h-screen bg-[#0F1219]">
      <Header 
        onUploadClick={() => setShowUploadPanel(true)} 
        showUploadButton={true}
        searchPlaceholder="Search videos..."
      />

      <div className="p-8">
        {deleteError && (
          <div className="mb-6 p-3 rounded-xl bg-red-500/10 border border-red-500/30 text-red-300 text-sm">
            {deleteError}
          </div>
        )}
        {/* Page Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-white mb-2">Video Library</h1>
          <p className="text-gray-500">{stats.totalVideos} videos uploaded</p>
        </div>

        {/* Category Tabs */}
        <div className="flex gap-2 mb-8 overflow-x-auto pb-2">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-4 py-2 rounded-lg font-medium whitespace-nowrap transition-colors ${
                selectedCategory === cat
                  ? 'bg-orange-500 text-white'
                  : 'bg-white/5 text-gray-400 hover:bg-white/10 hover:text-white'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Videos Grid */}
        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {[...Array(8)].map((_, i) => (
              <div key={i} className="glass rounded-2xl overflow-hidden animate-pulse">
                <div className="aspect-video bg-gray-700"></div>
                <div className="p-4 space-y-3">
                  <div className="h-4 bg-gray-700 rounded w-3/4"></div>
                  <div className="h-3 bg-gray-700 rounded w-1/2"></div>
                </div>
              </div>
            ))}
          </div>
        ) : videos.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {videos.map((video) => (
              <VideoCard
                key={video.id}
                video={video}
                onClick={() => setActiveVideo(video)}
                onDelete={() => deleteVideo(video)}
                deleting={deletingVideoId === video.id}
              />
            ))}
          </div>
        ) : (
          <div className="text-center py-20">
            <div className="w-20 h-20 bg-white/5 rounded-full flex items-center justify-center mx-auto mb-6">
              <Video className="w-10 h-10 text-gray-600" />
            </div>
            <h3 className="text-xl font-semibold text-white mb-2">No videos yet</h3>
            <p className="text-gray-500 mb-6">Upload your first exercise video to get started</p>
            <button
              onClick={() => setShowUploadPanel(true)}
              className="px-6 py-3 bg-orange-500 hover:bg-orange-600 text-white font-medium rounded-xl transition-colors"
            >
              Upload Video
            </button>
          </div>
        )}
      </div>

      {/* Stats Bar */}
      <div className="fixed bottom-0 left-64 right-0 glass border-t border-white/10">
        <div className="flex items-center justify-center gap-16 py-4 px-8">
          <StatItem icon={Video} label="Total Videos" value={stats.totalVideos.toLocaleString()} />
          <StatItem icon={ListVideo} label="Routines Created" value={stats.totalRoutines.toLocaleString()} />
        </div>
      </div>

      {/* Upload Panel */}
      <UploadPanel
        isOpen={showUploadPanel}
        onClose={() => setShowUploadPanel(false)}
        onUploadComplete={() => {
          loadVideos();
          loadStats();
        }}
      />

      {/* Video Player Modal */}
      {activeVideo && (
        <div className="fixed inset-0 bg-black/70 z-50 flex items-center justify-center p-6">
          <div className="glass w-full max-w-4xl rounded-2xl overflow-hidden border border-white/10">
            <div className="flex items-center justify-between px-5 py-3 border-b border-white/10">
              <div className="min-w-0">
                <p className="text-white font-semibold truncate">{activeVideo.title}</p>
                <p className="text-xs text-gray-500 truncate">{activeVideo.playback_url || ''}</p>
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => deleteVideo(activeVideo)}
                  disabled={deletingVideoId === activeVideo.id}
                  className="px-3 py-1.5 rounded-lg bg-red-500/10 text-red-300 hover:bg-red-500/20 disabled:opacity-60 flex items-center gap-2"
                  title="Delete clip"
                >
                  <Trash2 className="w-4 h-4" />
                  {deletingVideoId === activeVideo.id ? 'Deleting…' : 'Delete'}
                </button>
                <button
                  onClick={() => setActiveVideo(null)}
                  className="px-3 py-1.5 rounded-lg bg-white/5 text-gray-300 hover:bg-white/10"
                >
                  Close
                </button>
              </div>
            </div>
            <div className="bg-black">
              {(ingestingActiveVideo || ingestError) && (
                <div className="px-5 py-3 border-b border-white/10">
                  {ingestingActiveVideo ? (
                    <p className="text-sm text-gray-300">Preparing Cloudflare player…</p>
                  ) : (
                    <p className="text-sm text-red-300">{ingestError}</p>
                  )}
                </div>
              )}
              {cloudflareStatusText && (
                <div className="px-5 py-3 border-b border-white/10">
                  <p className="text-sm text-gray-300">{cloudflareStatusText}</p>
                </div>
              )}
              <VideoPlayer video={activeVideo} />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function StatItem({ icon: Icon, label, value }: { icon: React.ElementType; label: string; value: string }) {
  return (
    <div className="flex items-center gap-4">
      <div className="w-12 h-12 bg-white/5 rounded-xl flex items-center justify-center">
        <Icon className="w-6 h-6 text-gray-400" />
      </div>
      <div>
        <p className="text-sm text-gray-500">{label}</p>
        <p className="text-xl font-bold text-white">{value}</p>
        </div>
    </div>
  );
}

function VideoPlayer({ video }: { video: VideoType }) {
  const playbackUrl = (video.playback_url || '').trim();
  const sourceUrl = (video.source_url || '').trim();
  const playbackIsCloudflare = /videodelivery\.net|cloudflarestream\.com/i.test(playbackUrl);
  const sourceIsCloudflare = /videodelivery\.net|cloudflarestream\.com/i.test(sourceUrl);
  const directUrl =
    playbackUrl && !playbackIsCloudflare
      ? playbackUrl
      : sourceUrl && !sourceIsCloudflare
        ? sourceUrl
        : '';

  // Legacy/fallback source: allow direct playback when the source is not Cloudflare.
  if (directUrl) {
    return (
      <video
        src={directUrl}
        controls
        className="w-full aspect-video bg-black"
      />
    );
  }

  // Use the same Cloudflare Stream iframe player for everything.
  const status = (video.status || '').toString().toLowerCase();
  if (status === 'error') {
    return (
      <div className="p-6 text-gray-300">
        <p className="mb-2">Cloudflare failed to process this clip.</p>
        <p className="text-xs text-gray-500">See the Cloudflare error reason above and re-upload with the corrected limit/settings.</p>
      </div>
    );
  }
  if (status && status !== 'ready') {
    return (
      <div className="p-6 text-gray-300">
        <p className="mb-2">This clip is still processing on Cloudflare.</p>
        <p className="text-xs text-gray-500">Give it a minute, then reopen (or refresh) to play.</p>
      </div>
    );
  }

  const cfIdRaw = (video.cloudflare_video_id || '').trim();
  const cfIdFromPlayback =
    typeof video.playback_url === 'string' && video.playback_url.length > 0
      ? (video.playback_url.match(/videodelivery\.net\/([^/?#]+)/i)?.[1] ||
          video.playback_url.match(/cloudflarestream\.com\/([^/?#]+)/i)?.[1] ||
          null)
      : null;
  const cfId = cfIdRaw && !cfIdRaw.startsWith('fal-') ? cfIdRaw : cfIdFromPlayback;

  if (cfId) {
    return (
      <iframe
        src={`https://iframe.videodelivery.net/${cfId}`}
        className="w-full aspect-video"
        allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture;"
        allowFullScreen
      />
    );
  }

  return (
    <div className="p-6 text-gray-300">
      <p className="mb-2">This video is not available in Cloudflare Stream yet.</p>
      <p className="text-xs text-gray-500">Ask an admin to re-upload/ingest it so it can be played consistently.</p>
    </div>
  );
}
