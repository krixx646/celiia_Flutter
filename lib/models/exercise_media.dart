/// A row from the shared `exercise_media` reference library.
///
/// This is intentionally separate from [Video]/Cloudflare Stream — it's a
/// TEMPORARY stock GIF fallback shown for routine steps that don't have a
/// real filmed video yet. Real videos always take priority when available.
class ExerciseMedia {
  final String slug;
  final String displayName;
  final String? muscleGroup;
  final String category;
  final String? gifUrl;
  final bool isPlaceholder;

  const ExerciseMedia({
    required this.slug,
    required this.displayName,
    this.muscleGroup,
    required this.category,
    this.gifUrl,
    this.isPlaceholder = true,
  });

  factory ExerciseMedia.fromJson(Map<String, dynamic> json) {
    return ExerciseMedia(
      slug: json['slug'] as String,
      displayName: json['display_name'] as String,
      muscleGroup: json['muscle_group'] as String?,
      category: json['category'] as String,
      gifUrl: json['gif_url'] as String?,
      isPlaceholder: json['is_placeholder'] as bool? ?? true,
    );
  }
}
