'use client';

import { Play, Dumbbell, Zap, Trash2 } from 'lucide-react';
import { Video } from '@/lib/supabase';
import { formatDuration, formatDate, cn, resolveAnyVideoThumbnailUrl } from '@/lib/utils';

interface VideoCardProps {
  video: Video;
  onClick?: () => void;
  onDelete?: () => void;
  deleting?: boolean;
}

const bodyPartLabels: Record<string, string> = {
  arms: 'Arms',
  shoulders: 'Shoulders',
  chest: 'Chest',
  back: 'Back',
  core: 'Core',
  abs: 'Abs',
  legs: 'Legs',
  glutes: 'Glutes',
  full_body: 'Full Body',
};

const difficultyColors: Record<string, string> = {
  beginner: 'text-green-400',
  intermediate: 'text-yellow-400',
  advanced: 'text-red-400',
};

export default function VideoCard({ video, onClick, onDelete, deleting }: VideoCardProps) {
  const statusColors = {
    ready: 'status-ready',
    processing: 'status-processing',
    error: 'status-error',
    pending: 'status-pending',
  };

  const categoryColors: Record<string, string> = {
    yoga: 'bg-purple-500/20 text-purple-400',
    hiit: 'bg-red-500/20 text-red-400',
    strength: 'bg-blue-500/20 text-blue-400',
    cardio: 'bg-green-500/20 text-green-400',
    flexibility: 'bg-cyan-500/20 text-cyan-400',
    dance: 'bg-pink-500/20 text-pink-400',
    pilates: 'bg-indigo-500/20 text-indigo-400',
    warmup: 'bg-orange-500/20 text-orange-400',
    cooldown: 'bg-sky-500/20 text-sky-400',
  };

  return (
    <div 
      className="glass rounded-2xl overflow-hidden cursor-pointer hover:border-orange-500/30 transition-all duration-200 group"
      onClick={onClick}
    >
      {/* Thumbnail */}
      <div className="relative aspect-video bg-gray-800">
        {resolveAnyVideoThumbnailUrl(video) ? (
          <img 
            src={resolveAnyVideoThumbnailUrl(video)!} 
            alt={video.title}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-gray-700 to-gray-800">
            <Play className="w-12 h-12 text-gray-600" />
          </div>
        )}

        {/* Status Badge */}
        <div className={cn(
          "absolute top-3 left-3 px-2 py-1 rounded-md text-xs font-medium flex items-center gap-1",
          statusColors[video.status]
        )}>
          <span className="w-1.5 h-1.5 rounded-full bg-current"></span>
          {video.status.charAt(0).toUpperCase() + video.status.slice(1)}
        </div>

        {/* AI Generated Badge */}
        {video.is_ai_generated && (
          <div className="absolute top-3 left-20 px-2 py-1 bg-purple-500/20 text-purple-400 rounded-md text-xs font-medium flex items-center gap-1">
            <Zap className="w-3 h-3" />
            AI
          </div>
        )}

        {/* Duration */}
        <div className="absolute bottom-3 right-3 px-2 py-1 bg-black/70 rounded-md text-xs font-medium text-white">
          {formatDuration(video.duration_seconds)}
        </div>

        {/* Delete */}
        {onDelete && (
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              onDelete();
            }}
            disabled={Boolean(deleting)}
            title="Delete clip"
            className={cn(
              "absolute top-3 right-3 p-2 rounded-md bg-black/60 text-red-300 hover:text-red-200 hover:bg-red-500/20 transition-colors",
              "opacity-0 group-hover:opacity-100",
              deleting ? "cursor-not-allowed opacity-70" : ""
            )}
          >
            <Trash2 className="w-4 h-4" />
          </button>
        )}

        {/* Play overlay on hover */}
        <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
          <div className="w-14 h-14 bg-orange-500 rounded-full flex items-center justify-center">
            <Play className="w-6 h-6 text-white ml-1" />
          </div>
        </div>
      </div>

      {/* Info */}
      <div className="p-4">
        <h3 className="font-semibold text-white truncate mb-2">{video.title}</h3>
        
        <div className="flex items-center gap-2 mb-3 flex-wrap">
          {video.category && (
            <span className={cn(
              "px-2 py-0.5 rounded text-xs font-medium",
              categoryColors[video.category.toLowerCase()] || 'bg-gray-500/20 text-gray-400'
            )}>
              {video.category}
            </span>
          )}
          {video.body_part && (
            <span className="px-2 py-0.5 rounded text-xs font-medium bg-white/10 text-gray-300 flex items-center gap-1">
              <Dumbbell className="w-3 h-3" />
              {bodyPartLabels[video.body_part] || video.body_part}
            </span>
          )}
        </div>

        <div className="flex items-center justify-between text-xs text-gray-500">
          <span className={cn(
            "font-medium capitalize",
            difficultyColors[video.difficulty?.toLowerCase() || 'beginner'] || 'text-gray-400'
          )}>
            {video.difficulty || 'Beginner'}
          </span>
          <span>{formatDate(video.uploaded_at)}</span>
        </div>
      </div>
    </div>
  );
}
