/// Environment configuration for API keys and service credentials.
/// 
/// SECURITY NOTE: In production, use --dart-define or a secrets manager.
/// These values are compiled into the app binary.
class Env {
  // ─────────────────────────────────────────────────────────────────────────
  // ImgBB (Image Upload)
  // ─────────────────────────────────────────────────────────────────────────
  static const String imgbbKey = String.fromEnvironment('IMGBB_KEY', defaultValue: '');

  // ─────────────────────────────────────────────────────────────────────────
  // OpenAI (AI Routine Generation)
  // ─────────────────────────────────────────────────────────────────────────
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Celia backend (Vercel/Next.js) - used by the mobile app
  // ─────────────────────────────────────────────────────────────────────────
  static const String celiaBackendBaseUrl = String.fromEnvironment(
    'CELIA_BACKEND_BASE_URL',
    defaultValue: '',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Cloudflare Stream (Video Hosting & CDN)
  // ─────────────────────────────────────────────────────────────────────────
  static const String cloudflareAccountId = String.fromEnvironment(
    'CLOUDFLARE_ACCOUNT_ID',
    defaultValue: '',
  );
  static const String cloudflareApiToken = String.fromEnvironment(
    'CLOUDFLARE_API_TOKEN',
    defaultValue: '',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Supabase (Database, Auth, Storage)
  // ─────────────────────────────────────────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  // Service role key - ONLY for server-side/admin operations, never expose in client
  // static const String supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
