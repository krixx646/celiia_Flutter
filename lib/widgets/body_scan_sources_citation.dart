import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

/// Method and limits behind the body composition figures (App Store 1.4.1).
///
/// Body fat from photos is an estimate, and the studies below are candid about
/// the error band — particularly that agreement is much weaker for tracking
/// change over time than for a single measurement. Anywhere the app shows one
/// of these numbers, this belongs on the same screen.
class BodyScanSourcesCitation extends StatelessWidget {
  const BodyScanSourcesCitation({
    super.key,
    required this.theme,
    this.compact = false,
    this.onDark = false,
  });

  final ThemeProvider theme;
  final bool compact;
  final bool onDark;

  static const sources = <({String label, String url})>[
    (
      label: 'AI 2D-photo body fat vs DXA (npj Digital Medicine, 2025)',
      url: 'https://www.nature.com/articles/s41746-024-01380-6',
    ),
    (
      label: 'Smartphone 3D avatar body composition (Front. Nutr., 2024)',
      url: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC11491362/',
    ),
    (
      label: 'Longitudinal agreement over 12 weeks (Br J Nutr, 2023)',
      url: 'https://doi.org/10.1017/s0007114523000259',
    ),
    (
      label: 'Bodygram measurement platform',
      url: 'https://docs.bodygram.com/platform',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleColor = onDark
        ? Colors.white.withValues(alpha: 0.92)
        : theme.textPrimary;
    final bodyColor = onDark
        ? Colors.white.withValues(alpha: 0.72)
        : theme.textSecondary;
    final linkColor = onDark ? Colors.white : theme.accentOrange;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: onDark ? Colors.black.withValues(alpha: 0.28) : theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: onDark ? Colors.white.withValues(alpha: 0.18) : theme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bodyScanSourcesTitle,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 13 : 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.bodyScanSourcesBody,
            style: TextStyle(color: bodyColor, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.bodyScanDisclaimer,
            style: TextStyle(
              color: bodyColor,
              height: 1.35,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          ...sources.map(
            (source) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => _open(source.url),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.open_in_new, size: 14, color: linkColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        source.label,
                        style: TextStyle(
                          color: linkColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: linkColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
