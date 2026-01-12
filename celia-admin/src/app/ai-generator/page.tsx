'use client';

import { useEffect, useState } from 'react';
import { Sparkles, Play, Clock, Zap, Video, Wand2, AlertCircle, CheckCircle, XCircle } from 'lucide-react';
import Header from '@/components/Header';
import { cn } from '@/lib/utils';

const bodyParts = [
  { id: 'arms', label: 'Arms', emoji: '💪' },
  { id: 'shoulders', label: 'Shoulders', emoji: '🤷' },
  { id: 'chest', label: 'Chest', emoji: '🫁' },
  { id: 'back', label: 'Back', emoji: '🔙' },
  { id: 'core', label: 'Core', emoji: '🎯' },
  { id: 'abs', label: 'Abs', emoji: '🧱' },
  { id: 'legs', label: 'Legs', emoji: '🦵' },
  { id: 'glutes', label: 'Glutes', emoji: '🍑' },
  { id: 'full_body', label: 'Full Body', emoji: '🏋️' },
];

const exerciseTypes = [
  { id: 'warmup', label: 'Warm-up', emoji: '🔥' },
  { id: 'cardio', label: 'Cardio', emoji: '🏃' },
  { id: 'strength', label: 'Strength', emoji: '💪' },
  { id: 'flexibility', label: 'Flexibility', emoji: '🧘' },
  { id: 'cooldown', label: 'Cool-down', emoji: '❄️' },
  { id: 'hiit', label: 'HIIT', emoji: '⚡' },
];

const difficultyLevels = [
  { id: 'beginner', label: 'Beginner', color: 'text-green-400' },
  { id: 'intermediate', label: 'Intermediate', color: 'text-yellow-400' },
  { id: 'advanced', label: 'Advanced', color: 'text-red-400' },
];

const environments = [
  { id: 'home_gym', label: 'Home Gym', description: 'Bright minimalist room with natural light' },
  { id: 'studio', label: 'Fitness Studio', description: 'Professional gym with mirrors' },
  { id: 'outdoor', label: 'Outdoor', description: 'Park or backyard setting' },
  { id: 'living_room', label: 'Living Room', description: 'Cozy home environment' },
];

interface GeneratedVideo {
  id: string;
  title: string;
  status: 'generating' | 'completed' | 'failed';
  videoUrl?: string;
  error?: string;
}

export default function AIGeneratorPage() {
  const [exerciseName, setExerciseName] = useState('');
  const [selectedBodyPart, setSelectedBodyPart] = useState('');
  const [selectedType, setSelectedType] = useState('');
  const [difficulty, setDifficulty] = useState('beginner');
  const [duration, setDuration] = useState(10);
  const [environment, setEnvironment] = useState('home_gym');
  const [aspectRatio, setAspectRatio] = useState<'9:16' | '16:9' | '1:1'>('9:16');
  const [includeAudio, setIncludeAudio] = useState(true);
  const [promptText, setPromptText] = useState('');
  const [promptDirty, setPromptDirty] = useState(false);
  const [generating, setGenerating] = useState(false);
  const [generatedVideos, setGeneratedVideos] = useState<GeneratedVideo[]>([]);
  const [error, setError] = useState('');
  const [status, setStatus] = useState<{ falOk: boolean; cloudflareOk: boolean; missing: string[] } | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch('/api/admin/status');
        const json = await res.json();
        setStatus({ falOk: Boolean(json.falOk), cloudflareOk: Boolean(json.cloudflareOk), missing: json.missing || [] });
      } catch (_) {
        setStatus({ falOk: false, cloudflareOk: false, missing: ['Unable to reach /api/admin/status'] });
      }
    })();
  }, []);

  const buildPrompt = () => {
    const env = environments.find(e => e.id === environment);
    const body = bodyParts.find(b => b.id === selectedBodyPart);
    const type = exerciseTypes.find(t => t.id === selectedType);
    
    return `A fit athletic person demonstrates ${exerciseName} exercise in a ${env?.description || 'bright minimalist home gym'}. ${body?.label || ''} focused ${type?.label || 'exercise'}. The person wears modern athletic wear - a fitted sports top and leggings. Natural lighting, camera is static and front-facing, capturing full body in ${aspectRatio === '9:16' ? 'vertical mobile format' : aspectRatio === '16:9' ? 'horizontal widescreen' : 'square format'}. Movements are slow, controlled, and demonstrate proper form. Professional fitness content quality, clean aesthetic.`;
  };

  useEffect(() => {
    // Keep prompt auto-generated until the user edits it.
    if (promptDirty) return;
    if (!exerciseName.trim()) {
      setPromptText('');
      return;
    }
    setPromptText(buildPrompt());
  }, [exerciseName, selectedBodyPart, selectedType, difficulty, duration, environment, aspectRatio, promptDirty]);

  const handleGenerate = async () => {
    if (!exerciseName.trim() || !selectedBodyPart || !selectedType) {
      setError('Please fill in exercise name, body part, and exercise type');
      return;
    }

    setError('');
    setGenerating(true);

    const newVideo: GeneratedVideo = {
      id: Date.now().toString(),
      title: exerciseName,
      status: 'generating',
    };
    
    setGeneratedVideos(prev => [newVideo, ...prev]);

    try {
      const prompt = (promptText || '').trim();
      if (!prompt) {
        throw new Error('Prompt is empty. Please edit the prompt and try again.');
      }

      const response = await fetch('/api/generate-video', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prompt,
          exerciseName,
          bodyPart: selectedBodyPart,
          difficulty,
          exerciseType: selectedType,
          duration,
          aspectRatio,
          includeAudio,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Generation failed');
      }

      // Update the video status
      setGeneratedVideos(prev => 
        prev.map(v => 
          v.id === newVideo.id 
            ? { ...v, status: 'completed', videoUrl: data.video.videoUrl }
            : v
        )
      );

      // Reset form
      setExerciseName('');
      setPromptText('');
      setPromptDirty(false);

    } catch (err: any) {
      console.error('Generation error:', err);
      setGeneratedVideos(prev => 
        prev.map(v => 
          v.id === newVideo.id 
            ? { ...v, status: 'failed', error: err.message }
            : v
        )
      );
      setError(err.message);
    } finally {
      setGenerating(false);
    }
  };

  // Pricing note:
  // fal.ai's public pricing table lists Kling 2.5 Turbo Pro at $0.07 / second.
  // Kling 2.6 pricing (and any audio premium) is not listed publicly, so treat any figure as an estimate.
  const pricePerSecondEstimate = 0.07;
  const estimatedCost = duration * pricePerSecondEstimate;

  return (
    <div className="min-h-screen bg-[#0F1219]">
      <Header showSearch={false} />

      <div className="p-8 max-w-5xl mx-auto">
        {/* Page Header */}
        <div className="text-center mb-10">
          <div className="w-16 h-16 bg-gradient-to-br from-orange-500 to-pink-500 rounded-2xl flex items-center justify-center mx-auto mb-6">
            <Sparkles className="w-8 h-8 text-white" />
          </div>
          <h1 className="text-3xl font-bold text-white mb-2">AI Video Generator</h1>
          <p className="text-gray-500">Generate exercise videos using Kling (fal.ai). Audio support depends on server config.</p>
        </div>

        {/* Setup Warning (only when missing) */}
        {status && !status.falOk && (
          <div className="glass rounded-2xl p-6 mb-8 border border-yellow-500/30 bg-yellow-500/5">
            <div className="flex items-start gap-4">
              <AlertCircle className="w-6 h-6 text-yellow-500 flex-shrink-0 mt-0.5" />
              <div>
                <h3 className="font-semibold text-white mb-1">Setup Required</h3>
                <p className="text-sm text-gray-400">
                  Video generation is not configured on the server. Missing:
                </p>
                <ul className="list-disc ml-5 text-sm text-gray-300 mt-2 space-y-1">
                  {(status.missing || []).map((m) => (
                    <li key={m}>{m}</li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Generator Form */}
          <div className="lg:col-span-2 glass rounded-2xl p-8">
            <h2 className="text-xl font-bold text-white mb-6">Create Exercise Video</h2>
            
            {/* Exercise Name */}
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Exercise Name *
              </label>
              <input
                type="text"
                value={exerciseName}
                onChange={(e) => setExerciseName(e.target.value)}
                placeholder="e.g., Lateral Arm Raises, Squats, Jumping Jacks..."
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-orange-500/50"
              />
            </div>

            {/* Body Part */}
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Target Body Part *
              </label>
              <div className="grid grid-cols-4 gap-2">
                {bodyParts.map((part) => (
                  <button
                    key={part.id}
                    onClick={() => setSelectedBodyPart(part.id)}
                    className={cn(
                      "flex flex-col items-center gap-1 px-3 py-3 rounded-xl text-sm font-medium transition-colors",
                      selectedBodyPart === part.id
                        ? "bg-orange-500/20 text-orange-400 border border-orange-500/50"
                        : "bg-white/5 text-gray-400 border border-white/10 hover:bg-white/10"
                    )}
                  >
                    <span className="text-lg">{part.emoji}</span>
                    <span className="text-xs">{part.label}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Exercise Type */}
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Exercise Type *
              </label>
              <div className="flex flex-wrap gap-2">
                {exerciseTypes.map((type) => (
                  <button
                    key={type.id}
                    onClick={() => setSelectedType(type.id)}
                    className={cn(
                      "flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-colors",
                      selectedType === type.id
                        ? "bg-orange-500/20 text-orange-400 border border-orange-500/50"
                        : "bg-white/5 text-gray-400 border border-white/10 hover:bg-white/10"
                    )}
                  >
                    <span>{type.emoji}</span>
                    {type.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Difficulty */}
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Difficulty Level
              </label>
              <div className="flex gap-2">
                {difficultyLevels.map((level) => (
                  <button
                    key={level.id}
                    onClick={() => setDifficulty(level.id)}
                    className={cn(
                      "flex-1 py-2 px-4 rounded-xl text-sm font-medium transition-colors",
                      difficulty === level.id
                        ? `bg-orange-500/20 ${level.color} border border-orange-500/50`
                        : "bg-white/5 text-gray-400 border border-white/10 hover:bg-white/10"
                    )}
                  >
                    {level.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Environment */}
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Environment / Setting
              </label>
              <div className="grid grid-cols-2 gap-2">
                {environments.map((env) => (
                  <button
                    key={env.id}
                    onClick={() => setEnvironment(env.id)}
                    className={cn(
                      "text-left px-4 py-3 rounded-xl transition-colors",
                      environment === env.id
                        ? "bg-orange-500/20 border border-orange-500/50"
                        : "bg-white/5 border border-white/10 hover:bg-white/10"
                    )}
                  >
                    <p className={cn("font-medium text-sm", environment === env.id ? "text-orange-400" : "text-white")}>
                      {env.label}
                    </p>
                    <p className="text-xs text-gray-500">{env.description}</p>
                  </button>
                ))}
              </div>
            </div>

            {/* Duration & Aspect Ratio */}
            <div className="grid grid-cols-2 gap-6 mb-6">
              <div>
                <label className="block text-sm font-medium text-gray-400 mb-2">
                  Duration: {duration} seconds
                </label>
                <input
                  type="range"
                  min={5}
                  max={10}
                  step={5}
                  value={duration}
                  onChange={(e) => setDuration(Number(e.target.value))}
                  className="w-full h-2 bg-white/10 rounded-lg appearance-none cursor-pointer accent-orange-500"
                />
                <div className="flex justify-between text-xs text-gray-500 mt-1">
                  <span>5s</span>
                  <span>10s</span>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-400 mb-2">
                  Aspect Ratio
                </label>
                <div className="flex gap-2">
                  {[
                    { id: '9:16', label: '9:16', desc: 'Mobile' },
                    { id: '16:9', label: '16:9', desc: 'Wide' },
                    { id: '1:1', label: '1:1', desc: 'Square' },
                  ].map((ar) => (
                    <button
                      key={ar.id}
                      onClick={() => setAspectRatio(ar.id as any)}
                      className={cn(
                        "flex-1 py-2 rounded-lg text-xs font-medium transition-colors",
                        aspectRatio === ar.id
                          ? "bg-orange-500 text-white"
                          : "bg-white/5 text-gray-400 hover:bg-white/10"
                      )}
                    >
                      {ar.label}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* Audio Toggle */}
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Audio
              </label>
              <button
                type="button"
                onClick={() => setIncludeAudio((v) => !v)}
                className={cn(
                  "w-full flex items-center justify-between px-4 py-3 rounded-xl border transition-colors",
                  includeAudio ? "bg-orange-500/10 border-orange-500/40" : "bg-white/5 border-white/10"
                )}
              >
                <span className="text-white">{includeAudio ? 'Include audio' : 'No audio'}</span>
                <span className={cn("text-xs font-medium px-2 py-1 rounded-full", includeAudio ? "bg-green-500/20 text-green-400" : "bg-gray-500/20 text-gray-300")}>
                  {includeAudio ? 'ON' : 'OFF'}
                </span>
              </button>
              <p className="text-xs text-gray-500 mt-2">
                If audio is ON, the server must be configured with an audio-capable Kling model.
              </p>
            </div>

            {/* Error Display */}
            {error && (
              <div className="mb-6 p-4 bg-red-500/10 border border-red-500/30 rounded-xl flex items-center gap-3">
                <XCircle className="w-5 h-5 text-red-500" />
                <p className="text-sm text-red-400">{error}</p>
              </div>
            )}

            {/* Generate Button */}
            <button
              onClick={handleGenerate}
              disabled={generating || !exerciseName.trim() || !selectedBodyPart || !selectedType}
              className={cn(
                "w-full py-4 rounded-xl font-medium flex items-center justify-center gap-2 transition-colors",
                generating || !exerciseName.trim() || !selectedBodyPart || !selectedType
                  ? "bg-white/10 text-gray-500 cursor-not-allowed"
                  : "bg-gradient-to-r from-orange-500 to-pink-500 hover:from-orange-600 hover:to-pink-600 text-white"
              )}
            >
              {generating ? (
                <>
                  <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  Generating...
                </>
              ) : (
                <>
                  <Wand2 className="w-5 h-5" />
                  Generate Video
                </>
              )}
            </button>
          </div>

          {/* Preview & Queue */}
          <div className="space-y-6">
            {/* Prompt Preview */}
            <div className="glass rounded-2xl p-6">
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-medium text-gray-400">Prompt (editable)</h3>
                <button
                  type="button"
                  onClick={() => {
                    if (!exerciseName.trim()) return;
                    setPromptText(buildPrompt());
                    setPromptDirty(false);
                  }}
                  disabled={!exerciseName.trim()}
                  className={cn(
                    'text-xs px-2 py-1 rounded-lg transition-colors',
                    exerciseName.trim() ? 'bg-white/5 text-gray-300 hover:bg-white/10' : 'bg-white/5 text-gray-600 cursor-not-allowed'
                  )}
                >
                  Reset
                </button>
              </div>
              <textarea
                value={promptText}
                onChange={(e) => {
                  setPromptText(e.target.value);
                  setPromptDirty(true);
                }}
                placeholder={'Fill in the form to auto-generate a prompt, then edit it here…'}
                className="w-full min-h-44 px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-orange-500/50 text-sm leading-relaxed"
              />
              <p className="text-xs text-gray-500 mt-2">
                Tip: keep the camera static + full body framing; add form cues (slow, controlled, proper form).
              </p>
            </div>

            {/* Cost Summary */}
            <div className="glass rounded-2xl p-6">
              <h3 className="text-sm font-medium text-gray-400 mb-3">Cost Estimate</h3>
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-500">Duration</span>
                  <span className="text-white">{duration}s</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-500">Price per second (Kling 2.5 Turbo Pro)</span>
                  <span className="text-white">${pricePerSecondEstimate.toFixed(2)}/s</span>
                </div>
                <div className="border-t border-white/10 pt-2 mt-2">
                  <div className="flex justify-between">
                    <span className="font-medium text-white">Total</span>
                    <span className="font-bold text-orange-500">${estimatedCost.toFixed(2)} (estimate)</span>
                  </div>
                </div>
                <p className="text-xs text-gray-500 mt-2">
                  Kling 2.6 pricing (and any audio premium) is not listed publicly on fal.ai pricing.
                  If audio is ON, treat this as a lower-bound estimate.
                </p>
              </div>
            </div>

            {/* Generation Queue */}
            {generatedVideos.length > 0 && (
              <div className="glass rounded-2xl p-6">
                <h3 className="text-sm font-medium text-gray-400 mb-3">Generation History</h3>
                <div className="space-y-3 max-h-80 overflow-y-auto">
                  {generatedVideos.map((video) => (
                    <div key={video.id} className="flex items-center gap-3 p-3 bg-white/5 rounded-xl">
                      <div className={cn(
                        "w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0",
                        video.status === 'generating' ? 'bg-orange-500/20' : 
                        video.status === 'completed' ? 'bg-green-500/20' : 'bg-red-500/20'
                      )}>
                        {video.status === 'generating' ? (
                          <div className="w-4 h-4 border-2 border-orange-500/30 border-t-orange-500 rounded-full animate-spin" />
                        ) : video.status === 'completed' ? (
                          <CheckCircle className="w-5 h-5 text-green-500" />
                        ) : (
                          <XCircle className="w-5 h-5 text-red-500" />
                        )}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-medium text-white text-sm truncate">{video.title}</p>
                        <p className={cn(
                          "text-xs capitalize",
                          video.status === 'generating' ? 'text-orange-400' :
                          video.status === 'completed' ? 'text-green-400' : 'text-red-400'
                        )}>
                          {video.status === 'generating' ? 'Processing...' : video.status}
                        </p>
                      </div>
                      {video.videoUrl && (
                        <a
                          href={video.videoUrl}
                          target="_blank"
                          className="p-2 text-gray-400 hover:text-white transition-colors"
                        >
                          <Play className="w-4 h-4" />
                        </a>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
