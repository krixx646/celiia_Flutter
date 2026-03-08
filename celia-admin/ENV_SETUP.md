## Celia Admin — Environment setup

This dashboard uses **Supabase** as the database and **fal.ai** (Kling) for AI video generation.

### Required variables

Create a file named `celia-admin/.env.local` with:

```bash
# Supabase (client-side reads)
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...

# Supabase (server-side admin writes/reads via Next.js API routes)
SUPABASE_SERVICE_ROLE_KEY=...

# Cloudflare Stream (uploads + playback metadata)
CLOUDFLARE_ACCOUNT_ID=...
CLOUDFLARE_STREAM_API_TOKEN=...

# Optional: storage bucket for raw video backups
# Default is "video-backups" if omitted.
SUPABASE_VIDEO_BACKUP_BUCKET=video-backups

# fal.ai
FAL_KEY=...

# Mobile app AI routine generation (server-side)
OPENAI_API_KEY=...
FIREBASE_PROJECT_ID=...
```

### Protect the dashboard (recommended for cloud)

If you deploy this publicly, you MUST protect it (otherwise anyone can hit the API routes and burn your credits).

```bash
ADMIN_BASIC_AUTH_USER=celia
ADMIN_BASIC_AUTH_PASS=choose-a-strong-password
```

### Kling model selection (audio toggle)

The UI has an **Include audio** toggle.

Configure the model IDs:

```bash
# Base model (no-audio or default)
FAL_KLING_MODEL=fal-ai/kling-video/v2.5-turbo/pro/text-to-video

# Audio-capable model (used when toggle is ON)
FAL_KLING_MODEL_WITH_AUDIO=YOUR_AUDIO_MODEL_ID_HERE
```

If `FAL_KLING_MODEL_WITH_AUDIO` is not set, the server will fall back to `FAL_KLING_MODEL`.


