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

# Mobile app AI routine generation (server-side text model)
DEEPSEEK_API_KEY=...
DEEPSEEK_TEXT_MODEL=deepseek-v4-pro
# Optional override; defaults to DeepSeek's OpenAI-compatible endpoint.
# DEEPSEEK_TEXT_ENDPOINT=https://api.deepseek.com/v1/chat/completions
# Optional: while the real filmed-video pipeline is suspended (default),
# "Create Routine" builds routines only from the `exercise_media` stock GIF
# library. Set to "false" once enough real videos are uploaded and ready,
# so generated routines prefer a real video per exercise when one exists.
# SUSPEND_REAL_VIDEOS=true

# Mobile calorie scanner vision fallback
OPENAI_API_KEY=...
OPENAI_VISION_MODEL=gpt-5.6-luna
# Workout voice coaching (OpenAI TTS). tts-1 is cheap and low-latency for counts.
OPENAI_TTS_MODEL=tts-1
OPENAI_TTS_VOICE=nova
FIREBASE_PROJECT_ID=...

# Body Scan (Bodygram Platform)
# Sign up at https://platform.bodygram.com — the account page shows both
# values. The key is a server-side secret: it can create and read scans for
# the whole organisation and spend the scan quota, so it must never be sent
# to the app or committed.
BODYGRAM_ORG_ID=org_...
BODYGRAM_API_KEY=...
# Optional override; defaults to https://platform.bodygram.com
# BODYGRAM_BASE_URL=https://platform.bodygram.com

# Club app link in Profile (optional)
# CLUB_APP_URL=https://preview.builtwithrocket.new/thefitclub-0ewx?p=c
# CLUB_APP_ENABLED=true

# Body-scan IAP verification (required for paid scans)
# Google Play: service account JSON with Android Publisher access, as one line
# GOOGLE_PLAY_PACKAGE_NAME=eu.thefit.celia
# GOOGLE_PLAY_SERVICE_ACCOUNT_JSON={"type":"service_account",...}

# Apple IAP (prefer App Store Server API credentials)
# APPLE_BUNDLE_ID=eu.thefit.celia
# APPLE_IAP_ISSUER_ID=...
# APPLE_IAP_KEY_ID=...
# APPLE_IAP_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
# APPLE_IAP_ENVIRONMENT=sandbox
# Legacy StoreKit 1 receipts only:
# APPLE_IAP_SHARED_SECRET=...
```

### Body Scan setup

1. Run `supabase/migrations/20260903_body_scans.sql`. It creates the
   `body_scans` and `user_entitlements` tables, the atomic scan-quota
   functions, and the private `body-meshes` storage bucket.
2. Run `supabase/migrations/20261006_body_scan_billing.sql` for purchased
   scans (`bonus_scans`), the `purchases` audit table, and redeem codes.
3. Add `BODYGRAM_ORG_ID` and `BODYGRAM_API_KEY` above.
4. Create the consumable IAP product in Play Console and App Store Connect:
   - Product ID: `eu.thefit.celia.body_scan.single`
   - Price: €7.99
   - Type: consumable
5. Add the Google / Apple verification env vars above, then redeploy Vercel.
6. Free scans default to **0**. Access is purchase (`eu.thefit.celia.body_scan.single`)
   or a redeem code. Purchased/redeemed scans live in `bonus_scans`.
7. Dev / coach codes (example already seeded as `VAL-TEST` in migration):
   ```sql
   insert into public.scanner_codes (code, scans_grant, max_redemptions, note)
   values ('COACH-TRIAL1', 3, 50, 'Coach / trial pack')
   on conflict (code) do nothing;
   ```

Photos are never persisted: they pass through `/api/mobile/body-scan` in memory
on the way to Bodygram, and only the derived measurements and the converted
`.glb` mesh are stored.

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


