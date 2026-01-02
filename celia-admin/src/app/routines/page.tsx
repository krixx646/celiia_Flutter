'use client';

import { useState, useEffect } from 'react';
import { Plus, Play, Clock, Flame, Edit2, Trash2, MoreVertical, Search, ArrowUp, ArrowDown, X } from 'lucide-react';
import Header from '@/components/Header';
import type { Routine } from '@/lib/supabase';
import { cn, resolveAnyVideoThumbnailUrl } from '@/lib/utils';

type VideoRow = {
  id: string;
  title: string;
  thumbnail_url: string | null;
  duration_seconds: number;
  status: string;
  playback_url: string | null;
  cloudflare_video_id: string | null;
};

type StepDraft = {
  id: string;
  title: string;
  duration_seconds: number;
  video_id: string | null;
  thumbnail_url: string | null;
};

const difficultyColors = {
  easy: 'bg-green-500/20 text-green-400',
  medium: 'bg-yellow-500/20 text-yellow-400',
  hard: 'bg-red-500/20 text-red-400',
};

const categoryIcons: Record<string, string> = {
  strength: '💪',
  cardio: '🏃',
  flexibility: '🧘',
  mindfulness: '🧠',
  dance: '💃',
  hiit: '🔥',
  yoga: '🕉️',
  custom: '✨',
};

export default function RoutinesPage() {
  const [routines, setRoutines] = useState<Routine[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'published' | 'drafts'>('all');

  const [showCreate, setShowCreate] = useState(false);
  const [showEdit, setShowEdit] = useState(false);
  const [editingRoutine, setEditingRoutine] = useState<Routine | null>(null);
  const [createError, setCreateError] = useState<string>('');
  const [creating, setCreating] = useState(false);
  const [videos, setVideos] = useState<VideoRow[]>([]);
  const [videosLoading, setVideosLoading] = useState(false);
  const [videoSearch, setVideoSearch] = useState('');
  const [stepDrafts, setStepDrafts] = useState<StepDraft[]>([]);
  const [form, setForm] = useState({
    title: '',
    description: '',
    duration_minutes: 15,
    difficulty: 'easy',
    category: 'strength',
    is_published: false,
  });

  useEffect(() => {
    loadRoutines();
  }, [filter]);

  useEffect(() => {
    if (stepDrafts.length === 0) return;
    const totalSeconds = stepDrafts.reduce((sum, s) => sum + (Number(s.duration_seconds) || 0), 0);
    const mins = Math.max(1, Math.ceil(totalSeconds / 60));
    setForm((p) => ({ ...p, duration_minutes: mins }));
  }, [stepDrafts]);

  async function loadRoutines() {
    setLoading(true);
    try {
      const res = await fetch('/api/admin/routines', { method: 'GET' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to load routines');

      let data: Routine[] = json.routines || [];
      if (filter === 'published') data = data.filter((r) => r.is_published);
      if (filter === 'drafts') data = data.filter((r) => !r.is_published);

      setRoutines(data);
    } catch (error) {
      console.error('Error loading routines:', error);
    } finally {
      setLoading(false);
    }
  }

  async function togglePublish(routine: Routine) {
    try {
      const res = await fetch(`/api/admin/routines/${routine.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_published: !routine.is_published }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to update routine');
      loadRoutines();
    } catch (error) {
      console.error('Error toggling publish:', error);
    }
  }

  async function deleteRoutine(id: string) {
    if (!confirm('Are you sure you want to delete this routine?')) return;
    
    try {
      const res = await fetch(`/api/admin/routines/${id}`, { method: 'DELETE' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to delete routine');
      loadRoutines();
    } catch (error) {
      console.error('Error deleting routine:', error);
    }
  }

  function resolveVideoThumb(v: VideoRow): string | null {
    return resolveAnyVideoThumbnailUrl({
      thumbnail_url: v.thumbnail_url,
      cloudflare_video_id: v.cloudflare_video_id,
      playback_url: v.playback_url,
    });
  }

  function resetRoutineModalState() {
    setCreateError('');
    setVideoSearch('');
    setStepDrafts([]);
    setForm({
      title: '',
      description: '',
      duration_minutes: 15,
      difficulty: 'easy',
      category: 'strength',
      is_published: false,
    });
  }

  function openCreateRoutine() {
    setEditingRoutine(null);
    setShowEdit(false);
    setShowCreate(true);
    resetRoutineModalState();
  }

  function openEditRoutine(routine: Routine) {
    setEditingRoutine(routine);
    setShowCreate(false);
    setShowEdit(true);
    setCreateError('');
    setVideoSearch('');
    setForm({
      title: routine.title ?? '',
      description: routine.description ?? '',
      duration_minutes: routine.duration_minutes ?? 15,
      difficulty: routine.difficulty ?? 'easy',
      category: routine.category ?? 'strength',
      is_published: Boolean(routine.is_published),
    });
    setStepDrafts(
      (routine.steps || [])
        .slice()
        .sort((a, b) => (a.order_index ?? 0) - (b.order_index ?? 0))
        .map((s, idx) => ({
          id: s.id || `step-${idx}`,
          title: s.title,
          duration_seconds: s.duration_seconds,
          video_id: s.video_id ?? null,
          thumbnail_url: s.thumbnail_url ?? null,
        }))
    );
  }

  function addStepFromVideo(v: VideoRow) {
    const thumb = resolveVideoThumb(v);
    setStepDrafts((prev) => [
      ...prev,
      {
        id: (typeof crypto !== 'undefined' && 'randomUUID' in crypto ? crypto.randomUUID() : `step-${Date.now()}-${prev.length}`) as string,
        title: v.title,
        duration_seconds: v.duration_seconds || 60,
        video_id: v.id,
        thumbnail_url: thumb,
      },
    ]);
  }

  function removeStep(id: string) {
    setStepDrafts((prev) => prev.filter((s) => s.id !== id));
  }

  function moveStep(id: string, dir: -1 | 1) {
    setStepDrafts((prev) => {
      const idx = prev.findIndex((s) => s.id === id);
      if (idx < 0) return prev;
      const nextIdx = idx + dir;
      if (nextIdx < 0 || nextIdx >= prev.length) return prev;
      const copy = prev.slice();
      const tmp = copy[idx];
      copy[idx] = copy[nextIdx];
      copy[nextIdx] = tmp;
      return copy;
    });
  }

  async function createRoutine() {
    setCreating(true);
    setCreateError('');
    try {
      if (!form.title.trim()) throw new Error('Title is required');
      const steps = stepDrafts.map((s: any, idx: number) => ({
        id: s.id || `step-${Date.now()}-${idx}`,
        title: s.title,
        description: null,
        duration_seconds: Number(s.duration_seconds) || 60,
        video_id: s.video_id ?? null,
        thumbnail_url: s.thumbnail_url ?? null,
        order_index: idx,
      }));
      if (steps.length === 0) throw new Error('Add at least 1 step');

      const res = await fetch('/api/admin/routines', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: form.title.trim(),
          description: form.description.trim() || null,
          duration_minutes: Number(form.duration_minutes),
          difficulty: form.difficulty,
          category: form.category,
          is_published: form.is_published,
          is_curated: true,
          steps,
        }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to create routine');

      setShowCreate(false);
      resetRoutineModalState();
      await loadRoutines();
    } catch (e: any) {
      setCreateError(e?.message ?? String(e));
    } finally {
      setCreating(false);
    }
  }

  async function saveRoutineEdits() {
    if (!editingRoutine) return;
    setCreating(true);
    setCreateError('');
    try {
      if (!form.title.trim()) throw new Error('Title is required');
      const steps = stepDrafts.map((s, idx) => ({
        id: s.id || `step-${Date.now()}-${idx}`,
        title: s.title,
        description: null,
        duration_seconds: Number(s.duration_seconds) || 60,
        video_id: s.video_id ?? null,
        thumbnail_url: s.thumbnail_url ?? null,
        order_index: idx,
      }));
      if (steps.length === 0) throw new Error('Add at least 1 step');

      const res = await fetch(`/api/admin/routines/${editingRoutine.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: form.title.trim(),
          description: form.description.trim() || null,
          duration_minutes: Number(form.duration_minutes),
          difficulty: form.difficulty,
          category: form.category,
          is_published: form.is_published,
          steps,
        }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to update routine');

      setShowEdit(false);
      setEditingRoutine(null);
      resetRoutineModalState();
      await loadRoutines();
    } catch (e: any) {
      setCreateError(e?.message ?? String(e));
    } finally {
      setCreating(false);
    }
  }

  async function loadVideos() {
    setVideosLoading(true);
    try {
      const res = await fetch('/api/admin/videos');
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to load videos');
      setVideos(json.videos || []);
    } catch (e: any) {
      setCreateError(e?.message ?? String(e));
    } finally {
      setVideosLoading(false);
    }
  }

  const filteredVideos = videos
    .filter((v) => (v.status || '').toLowerCase() === 'ready')
    .filter((v) => v.title.toLowerCase().includes(videoSearch.toLowerCase()));

  return (
    <div className="min-h-screen bg-[#0F1219]">
      <Header searchPlaceholder="Search routines..." />

      <div className="p-8">
        {/* Page Header */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold text-white mb-2">Routines</h1>
            <p className="text-gray-500">{routines.length} routines created</p>
          </div>
          <button
            onClick={openCreateRoutine}
            className="flex items-center gap-2 px-6 py-3 bg-orange-500 hover:bg-orange-600 text-white font-medium rounded-xl transition-colors"
          >
            <Plus className="w-5 h-5" />
            Create Routine
          </button>
        </div>

        {(showCreate || showEdit) && (
          <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-6 z-50">
            <div className="glass rounded-2xl w-full max-w-5xl border border-white/10 max-h-[85vh] flex flex-col overflow-hidden">
              <div className="flex items-center justify-between px-6 py-4 border-b border-white/10">
                <h2 className="text-xl font-bold text-white">{showEdit ? 'Edit Routine' : 'Create Routine'}</h2>
                <button
                  onClick={() => {
                    setShowCreate(false);
                    setShowEdit(false);
                    setEditingRoutine(null);
                    setVideoSearch('');
                    setStepDrafts([]);
                  }}
                  className="text-gray-400 hover:text-white"
                >
                  ✕
                </button>
              </div>

              <div className="flex-1 overflow-y-auto px-6 py-4">
                {createError && (
                  <div className="mb-4 p-3 rounded-xl bg-red-500/10 border border-red-500/30 text-red-300 text-sm">
                    {createError}
                  </div>
                )}

                <div className="mb-4 text-sm text-gray-300">
                  <span className="text-gray-400">How to build a routine:</span>{' '}
                  <span className="text-gray-200">Load clips → click “+ Add” → set seconds → Create/Save.</span>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="md:col-span-3">
                  <label className="block text-sm text-gray-400 mb-1">Title *</label>
                  <input
                    value={form.title}
                    onChange={(e) => setForm((p) => ({ ...p, title: e.target.value }))}
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white"
                  />
                </div>
                <div className="md:col-span-3">
                  <label className="block text-sm text-gray-400 mb-1">Description</label>
                  <textarea
                    value={form.description}
                    onChange={(e) => setForm((p) => ({ ...p, description: e.target.value }))}
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white min-h-24"
                  />
                </div>
                <div>
                  <label className="block text-sm text-gray-400 mb-1">Duration (min)</label>
                  <input
                    type="number"
                    value={form.duration_minutes}
                    onChange={(e) => setForm((p) => ({ ...p, duration_minutes: Number(e.target.value) }))}
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white"
                  />
                </div>
                <div>
                  <label className="block text-sm text-gray-400 mb-1">Publish now</label>
                  <label className="flex items-center gap-2 text-gray-300 mt-2">
                    <input
                      type="checkbox"
                      checked={form.is_published}
                      onChange={(e) => setForm((p) => ({ ...p, is_published: e.target.checked }))}
                    />
                    Published
                  </label>
                </div>
                <div>
                  <label className="block text-sm text-gray-400 mb-1">Difficulty</label>
                  <select
                    value={form.difficulty}
                    onChange={(e) => setForm((p) => ({ ...p, difficulty: e.target.value }))}
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white"
                  >
                    <option value="easy">easy</option>
                    <option value="medium">medium</option>
                    <option value="hard">hard</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm text-gray-400 mb-1">Category</label>
                  <select
                    value={form.category}
                    onChange={(e) => setForm((p) => ({ ...p, category: e.target.value }))}
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white"
                  >
                    {['strength','cardio','flexibility','mindfulness','dance','hiit','yoga','custom'].map((c) => (
                      <option key={c} value={c}>{c}</option>
                    ))}
                  </select>
                </div>

                {/* Step Builder */}
                <div className="md:col-span-1">
                  <label className="block text-sm text-gray-400 mb-1">Clips</label>
                  <div className="flex items-center gap-2 mb-2">
                    <button
                      type="button"
                      onClick={() => loadVideos()}
                      className="px-3 py-2 rounded-xl bg-white/5 text-gray-300 hover:bg-white/10"
                    >
                      {videosLoading ? 'Loading…' : videos.length > 0 ? 'Refresh' : 'Load'}
                    </button>
                  </div>
                  <div className="relative mb-2">
                    <Search className="w-4 h-4 text-gray-500 absolute left-3 top-3" />
                    <input
                      value={videoSearch}
                      onChange={(e) => setVideoSearch(e.target.value)}
                      placeholder="Search clips…"
                      className="w-full pl-9 pr-3 py-2 rounded-xl bg-white/5 border border-white/10 text-white"
                    />
                  </div>
                  <div className="max-h-80 overflow-y-auto rounded-xl border border-white/10 bg-black/10">
                    {videos.length === 0 ? (
                      <div className="p-3 text-sm text-gray-500">Click “Load” to fetch available clips.</div>
                    ) : filteredVideos.length === 0 ? (
                      <div className="p-3 text-sm text-gray-500">No READY clips match your search.</div>
                    ) : (
                      filteredVideos.slice(0, 60).map((v) => {
                        const thumb = resolveVideoThumb(v);
                        return (
                          <button
                            type="button"
                            key={v.id}
                            onClick={() => addStepFromVideo(v)}
                            className="w-full flex items-center gap-3 px-3 py-2 text-left hover:bg-white/5 transition-colors"
                            title="Add to routine"
                          >
                            {thumb ? (
                              <img src={thumb} className="w-16 h-10 object-cover rounded-md" alt="" />
                            ) : (
                              <div className="w-16 h-10 rounded-md bg-white/5 flex items-center justify-center text-gray-500 text-xs">
                                no thumb
                              </div>
                            )}
                            <div className="flex-1 min-w-0">
                              <div className="text-sm text-white truncate">{v.title}</div>
                              <div className="text-xs text-gray-500">{v.duration_seconds}s</div>
                            </div>
                            <div className="text-xs text-orange-400">+ Add</div>
                          </button>
                        );
                      })
                    )}
                  </div>
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm text-gray-400 mb-1">Routine Steps *</label>
                  <p className="text-xs text-gray-500 mb-2">
                    Add clips one-by-one, set how long each should run, and reorder as needed.
                  </p>
                  <div className="rounded-xl border border-white/10 bg-black/10">
                    {stepDrafts.length === 0 ? (
                      <div className="p-4 text-sm text-gray-500">No steps yet. Add a clip from the left.</div>
                    ) : (
                      <div className="divide-y divide-white/10">
                        {stepDrafts.map((s, idx) => (
                          <div key={s.id} className="flex items-center gap-3 p-3">
                            <div className="w-8 text-xs text-gray-500">{idx + 1}</div>
                            {s.thumbnail_url ? (
                              <img src={s.thumbnail_url} className="w-16 h-10 object-cover rounded-md" alt="" />
                            ) : (
                              <div className="w-16 h-10 rounded-md bg-white/5 flex items-center justify-center text-gray-500 text-xs">
                                —
                              </div>
                            )}
                            <input
                              value={s.title}
                              onChange={(e) =>
                                setStepDrafts((prev) =>
                                  prev.map((x) => (x.id === s.id ? { ...x, title: e.target.value } : x))
                                )
                              }
                              className="flex-1 px-3 py-2 bg-white/5 border border-white/10 rounded-lg text-white"
                            />
                            <div className="flex items-center gap-2">
                              <input
                                type="number"
                                value={s.duration_seconds}
                                min={5}
                                onChange={(e) =>
                                  setStepDrafts((prev) =>
                                    prev.map((x) =>
                                      x.id === s.id ? { ...x, duration_seconds: Number(e.target.value) } : x
                                    )
                                  )
                                }
                                className="w-24 px-3 py-2 bg-white/5 border border-white/10 rounded-lg text-white"
                              />
                              <span className="text-xs text-gray-500">sec</span>
                            </div>
                            <div className="flex items-center gap-1">
                              <button
                                type="button"
                                onClick={() => moveStep(s.id, -1)}
                                className="p-2 rounded-lg bg-white/5 hover:bg-white/10 text-gray-300"
                                title="Move up"
                              >
                                <ArrowUp className="w-4 h-4" />
                              </button>
                              <button
                                type="button"
                                onClick={() => moveStep(s.id, 1)}
                                className="p-2 rounded-lg bg-white/5 hover:bg-white/10 text-gray-300"
                                title="Move down"
                              >
                                <ArrowDown className="w-4 h-4" />
                              </button>
                              <button
                                type="button"
                                onClick={() => removeStep(s.id)}
                                className="p-2 rounded-lg bg-red-500/10 hover:bg-red-500/20 text-red-300"
                                title="Remove"
                              >
                                <X className="w-4 h-4" />
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              </div>
              </div>

              <div className="px-6 py-4 border-t border-white/10 bg-black/10 flex items-center justify-between gap-3">
                <div className="text-xs text-gray-500">
                  Steps: <span className="text-gray-300 font-medium">{stepDrafts.length}</span>
                </div>
                <div className="flex items-center gap-3">
                  <button
                    onClick={() => {
                      setShowCreate(false);
                      setShowEdit(false);
                      setEditingRoutine(null);
                    }}
                    className="px-4 py-2 rounded-xl bg-white/5 text-gray-300 hover:bg-white/10"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={showEdit ? saveRoutineEdits : createRoutine}
                    disabled={creating}
                    className="px-4 py-2 rounded-xl bg-orange-500 text-white hover:bg-orange-600 disabled:bg-orange-500/50"
                  >
                    {creating ? (showEdit ? 'Saving…' : 'Creating…') : showEdit ? 'Save' : 'Create'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Filter Tabs */}
        <div className="flex gap-2 mb-8">
          {(['all', 'published', 'drafts'] as const).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={cn(
                "px-4 py-2 rounded-lg font-medium capitalize transition-colors",
                filter === f
                  ? 'bg-orange-500 text-white'
                  : 'bg-white/5 text-gray-400 hover:bg-white/10 hover:text-white'
              )}
            >
              {f}
            </button>
          ))}
        </div>

        {/* Routines Grid */}
        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="glass rounded-2xl p-6 animate-pulse">
                <div className="h-6 bg-gray-700 rounded w-3/4 mb-4"></div>
                <div className="h-4 bg-gray-700 rounded w-1/2 mb-6"></div>
                <div className="flex gap-4">
                  <div className="h-8 bg-gray-700 rounded w-20"></div>
                  <div className="h-8 bg-gray-700 rounded w-20"></div>
                </div>
              </div>
            ))}
          </div>
        ) : routines.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {routines.map((routine) => (
              <div key={routine.id} className="glass rounded-2xl overflow-hidden group">
                {/* Header */}
                <div className="p-6">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex items-center gap-3">
                      <span className="text-2xl">{categoryIcons[routine.category] || '📋'}</span>
                      <div>
                        <h3 className="font-semibold text-white">{routine.title}</h3>
                        <p className="text-sm text-gray-500 capitalize">{routine.category}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className={cn(
                        "px-2 py-1 rounded text-xs font-medium",
                        routine.is_published ? 'bg-green-500/20 text-green-400' : 'bg-gray-500/20 text-gray-400'
                      )}>
                        {routine.is_published ? 'Published' : 'Draft'}
                      </span>
                      <button className="p-1.5 text-gray-500 hover:text-white transition-colors">
                        <MoreVertical className="w-4 h-4" />
                      </button>
                    </div>
                  </div>

                  {routine.description && (
                    <p className="text-sm text-gray-400 mb-4 line-clamp-2">
                      {routine.description}
                    </p>
                  )}

                  {/* Stats */}
                  <div className="flex items-center gap-4 text-sm text-gray-500">
                    <span className="flex items-center gap-1">
                      <Clock className="w-4 h-4" />
                      {routine.duration_minutes} min
                    </span>
                    <span className={cn(
                      "px-2 py-0.5 rounded text-xs font-medium capitalize",
                      difficultyColors[routine.difficulty]
                    )}>
                      {routine.difficulty}
                    </span>
                    {routine.calories_burned && (
                      <span className="flex items-center gap-1">
                        <Flame className="w-4 h-4 text-orange-500" />
                        {routine.calories_burned} cal
                      </span>
                    )}
                  </div>

                  {/* Steps preview */}
                  <div className="mt-4 pt-4 border-t border-white/10">
                    <p className="text-xs text-gray-500 mb-2">{routine.steps.length} exercises</p>
                    <div className="flex flex-wrap gap-1">
                      {routine.steps.slice(0, 4).map((step, i) => (
                        <span key={i} className="px-2 py-1 bg-white/5 rounded text-xs text-gray-400">
                          {step.title}
                        </span>
                      ))}
                      {routine.steps.length > 4 && (
                        <span className="px-2 py-1 bg-white/5 rounded text-xs text-gray-400">
                          +{routine.steps.length - 4} more
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                {/* Actions */}
                <div className="flex border-t border-white/10">
                  <button 
                    onClick={() => togglePublish(routine)}
                    className="flex-1 py-3 text-sm font-medium text-gray-400 hover:text-white hover:bg-white/5 transition-colors flex items-center justify-center gap-2"
                  >
                    <Play className="w-4 h-4" />
                    {routine.is_published ? 'Unpublish' : 'Publish'}
                  </button>
                  <button
                    onClick={() => openEditRoutine(routine)}
                    className="flex-1 py-3 text-sm font-medium text-gray-400 hover:text-white hover:bg-white/5 transition-colors flex items-center justify-center gap-2 border-l border-white/10"
                  >
                    <Edit2 className="w-4 h-4" />
                    Edit
                  </button>
                  <button 
                    onClick={() => deleteRoutine(routine.id)}
                    className="py-3 px-4 text-sm font-medium text-red-400 hover:text-red-300 hover:bg-red-500/10 transition-colors flex items-center justify-center border-l border-white/10"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-20">
            <div className="w-20 h-20 bg-white/5 rounded-full flex items-center justify-center mx-auto mb-6">
              <Play className="w-10 h-10 text-gray-600" />
            </div>
            <h3 className="text-xl font-semibold text-white mb-2">No routines yet</h3>
            <p className="text-gray-500 mb-6">Create your first workout routine</p>
            <button className="px-6 py-3 bg-orange-500 hover:bg-orange-600 text-white font-medium rounded-xl transition-colors">
              Create Routine
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

