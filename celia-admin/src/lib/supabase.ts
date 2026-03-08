import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Types
export interface Video {
  id: string;
  title: string;
  description: string | null;
  category: string | null;
  body_part: string | null;
  difficulty: string | null;
  duration_seconds: number;
  cloudflare_video_id: string | null;
  playback_url: string | null;
  thumbnail_url: string | null;
  source_url: string | null;
  backup_bucket: string | null;
  backup_path: string | null;
  equipment: string[] | null;
  tags: string[] | null;
  is_ai_generated: boolean;
  status: 'pending' | 'processing' | 'ready' | 'error';
  uploaded_at: string;
  created_at: string;
  updated_at: string | null;
}

export interface Routine {
  id: string;
  title: string;
  description: string | null;
  duration_minutes: number;
  difficulty: 'easy' | 'medium' | 'hard';
  category: 'strength' | 'cardio' | 'flexibility' | 'mindfulness' | 'dance' | 'hiit' | 'yoga' | 'custom';
  thumbnail_url: string | null;
  steps: RoutineStep[];
  created_by: string;
  created_at: string;
  updated_at: string | null;
  is_published: boolean;
  is_curated: boolean;
  tags: string[];
  calories_burned: number | null;
  equipment: string | null;
}

export interface RoutineStep {
  id: string;
  title: string;
  description: string | null;
  duration_seconds: number;
  video_id: string | null;
  thumbnail_url: string | null;
  order_index: number;
}
