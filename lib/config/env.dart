/// Environment configuration for API keys and service credentials.
///
/// SECURITY NOTE: Only public client values should have defaults here.
/// Private provider keys must stay server-side in Vercel/Supabase.
class Env {
  // ImgBB (Image Upload)
  static const String imgbbKey = String.fromEnvironment(
    'IMGBB_KEY',
    defaultValue: '',
  );

  // OpenAI (AI Routine Generation)
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  // Celia backend (Vercel/Next.js) - used by the mobile app
  static const String celiaBackendBaseUrl = String.fromEnvironment(
    'CELIA_BACKEND_BASE_URL',
    defaultValue: 'https://celiia-flutter.vercel.app',
  );

  // Cloudflare Stream (Video Hosting & CDN)
  static const String cloudflareAccountId = String.fromEnvironment(
    'CLOUDFLARE_ACCOUNT_ID',
    defaultValue: '',
  );
  static const String cloudflareApiToken = String.fromEnvironment(
    'CLOUDFLARE_API_TOKEN',
    defaultValue: '',
  );

  // Supabase (Database, Auth, Storage)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zgwxdpxhddcswdmectsm.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpnd3hkcHhoZGRjc3dkbWVjdHNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyMTUwODcsImV4cCI6MjA3OTc5MTA4N30.8FheIZEAlu5tgqUlGuz1pYIKnYFkw2s5SaEA0uj1EDg',
  );

  /// Temporary stock-GIF fallback for routine steps that don't have a real
  /// filmed video yet. Real Cloudflare videos always take priority when
  /// available; this only fills the gap while filming is in progress.
  ///
  /// Flip to false any time to hide GIF fallbacks app-wide without deleting
  /// any code or data.
  static const bool enableGifFallback = bool.fromEnvironment(
    'ENABLE_GIF_FALLBACK',
    defaultValue: true,
  );

  /// Client request: pause the real Cloudflare video pipeline entirely and
  /// run every routine step on the stock GIF library until that pipeline is
  /// fully working end-to-end, then flip this back to false to resume real
  /// videos everywhere. This never deletes the video code paths — it just
  /// skips them, so re-enabling is a one-line change.
  static const bool suspendRealVideos = bool.fromEnvironment(
    'SUSPEND_REAL_VIDEOS',
    defaultValue: true,
  );
}
