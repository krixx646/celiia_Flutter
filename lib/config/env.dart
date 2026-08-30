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

  /// The stock GIF pack, suspended in favour of the client's filmed clips.
  ///
  /// Suspended rather than deleted, on the same terms as [suspendRealVideos]:
  /// the tables, resolvers and render paths all stay, but nothing sourced from
  /// the GIF pack reaches the screen while this is false. Flip it back on to
  /// restore GIF fallbacks app-wide.
  static const bool enableGifFallback = bool.fromEnvironment(
    'ENABLE_GIF_FALLBACK',
    defaultValue: false,
  );

  /// The Cloudflare Stream pipeline the app was originally built around. It
  /// was suspended while that pipeline was unfinished, and the client's
  /// filmed clip library (served from Supabase storage) has since replaced it
  /// for every routine. Left suspended rather than deleted so the code path
  /// is one flag away if Cloudflare is ever picked back up.
  static const bool suspendRealVideos = bool.fromEnvironment(
    'SUSPEND_REAL_VIDEOS',
    defaultValue: true,
  );

  /// Run routines through the guided, coached player: the demo clip loops
  /// while the app counts the prescribed reps, holds the clock on timed
  /// exercises, and rests with the user between sets.
  ///
  /// Turning this off falls back to the old playlist-style player, which is
  /// kept intact for routines built before sets and reps existed.
  static const bool enableGuidedWorkouts = bool.fromEnvironment(
    'ENABLE_GUIDED_WORKOUTS',
    defaultValue: true,
  );

  /// Spoken coaching during guided workouts (on-device TTS).
  ///
  /// When false, the guided player still counts and rests with haptics only.
  static const bool enableVoiceCoach = bool.fromEnvironment(
    'ENABLE_VOICE_COACH',
    defaultValue: true,
  );

  /// Push-to-talk input and spoken chat replies in the coach chat screen.
  ///
  /// Uses on-device speech recognition and TTS (no new paid APIs).
  static const bool enableChatVoice = bool.fromEnvironment(
    'ENABLE_CHAT_VOICE',
    defaultValue: true,
  );

  /// Native VRoid avatar (Filament on Android; SceneKit on iOS).
  ///
  /// On by default, same as [enableChatVoice]. Pass
  /// `--dart-define=ENABLE_VRM_AVATAR=false` to hide it without a rebuild of
  /// the native viewers.
  static const bool enableVrmAvatar = bool.fromEnvironment(
    'ENABLE_VRM_AVATAR',
    defaultValue: true,
  );
}
