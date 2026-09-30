import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/exercise_clip.dart';
import '../../providers/theme_provider.dart';
import '../../services/exercise_clip_library.dart';
import '../../utils/how_to_search.dart';
import '../../utils/responsive.dart';
import '../routines/video_player_screen.dart';
import 'how_to_series_screen.dart';

/// Equipment form guides. The user types one exercise or a whole series
/// ("dumbbell chest and triceps"); a single demo plays once from start to
/// finish, and a series plays each matching demo in turn with rests between.
class HowToTab extends StatefulWidget {
  const HowToTab({super.key});

  @override
  State<HowToTab> createState() => _HowToTabState();
}

class _HowToTabState extends State<HowToTab> {
  final ExerciseClipLibrary _library = ExerciseClipLibrary();
  final TextEditingController _search = TextEditingController();
  late Future<List<ExerciseClip>> _clips = _library.howTo();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _displayName(ExerciseClip clip, Locale locale) {
    if (locale.languageCode == 'es' && clip.nameEs.isNotEmpty) {
      return clip.nameEs;
    }
    return clip.nameEn;
  }

  void _playSeries(List<ExerciseClip> series, Locale locale) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HowToSeriesScreen(
          clips: series,
          titleFor: (clip) => _displayName(clip, locale),
        ),
      ),
    );
  }

  void _open(ExerciseClip clip, String title) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoUrl: clip.videoUrl,
          title: title,
          thumbnailUrl: clip.posterUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final locale = Localizations.localeOf(context);
    final padding = context.contentHorizontalPadding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 4),
          child: Text(
            l10n.libraryHowToIntro,
            style: TextStyle(color: theme.textSecondary, height: 1.35),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 8),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            style: TextStyle(color: theme.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.libraryHowToSearchHint,
              hintStyle: TextStyle(color: theme.textSecondary),
              prefixIcon: Icon(Icons.search, color: theme.textSecondary),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.close, color: theme.textSecondary),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: theme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(color: theme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(color: theme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(color: theme.accentOrange),
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ExerciseClip>>(
            future: _clips,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(theme.accentOrange),
                  ),
                );
              }
              final all = snapshot.data ?? const <ExerciseClip>[];
              if (all.isEmpty) {
                return _message(
                  theme,
                  l10n.libraryLoadFailed,
                  action: TextButton(
                    onPressed: () => setState(() {
                      _clips = ExerciseClipLibrary().howTo();
                    }),
                    child: Text(l10n.actionRetry),
                  ),
                );
              }
              final matches = rankHowToClips(all, _query);
              if (matches.isEmpty) {
                return _message(theme, l10n.libraryHowToNoMatch(_query.trim()));
              }
              final series = _query.trim().isEmpty
                  ? const <ExerciseClip>[]
                  : howToSeriesFor(matches);
              final showSeries = series.length > 1;
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(padding, 8, padding, 120),
                itemCount: matches.length + (showSeries ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (showSeries && index == 0) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: () => _playSeries(series, locale),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.accentOrange,
                          foregroundColor: Colors.black87,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        icon: const Icon(Icons.playlist_play_rounded),
                        label: Text(l10n.howToPlaySeries(series.length)),
                      ),
                    );
                  }
                  final clip = matches[index - (showSeries ? 1 : 0)];
                  final title = _displayName(clip, locale);
                  return _HowToCard(
                    theme: theme,
                    clip: clip,
                    title: title,
                    onTap: () => _open(clip, title),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _message(ThemeProvider theme, String text, {Widget? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: theme.textSecondary, size: 48),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
            if (action != null) ...[const SizedBox(height: 8), action],
          ],
        ),
      ),
    );
  }
}

class _HowToCard extends StatelessWidget {
  const _HowToCard({
    required this.theme,
    required this.clip,
    required this.title,
    required this.onTap,
  });

  final ThemeProvider theme;
  final ExerciseClip clip;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final seconds = clip.clipSeconds.round();
    final equipment = clip.equipment
        .map((tag) => tag.replaceAll('_', ' '))
        .join(', ');

    return Material(
      color: theme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: clip.posterUrl == null
                      ? _placeholder()
                      : Image.network(
                          clip.posterUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (equipment.isNotEmpty) equipment,
                        if (seconds > 0) '${seconds}s',
                      ].join('  •  '),
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill, color: theme.accentOrange, size: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1A1D2D),
      child: Icon(Icons.fitness_center, color: theme.textSecondary),
    );
  }
}
