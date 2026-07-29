/// Converts free text into a URL/lookup-safe slug, e.g. "Push Up (Knees)"
/// -> "push-up-knees". Mirrors `slugify()` in
/// tool/exercise_gif_review/translate_gif_library.py so exercise names
/// generated on either side resolve to the same key.
String slugify(String text) {
  final lower = text.toLowerCase();
  final dashed = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final trimmed = dashed.replaceAll(RegExp(r'^-+|-+$'), '');
  return trimmed.replaceAll(RegExp(r'-{2,}'), '-');
}
