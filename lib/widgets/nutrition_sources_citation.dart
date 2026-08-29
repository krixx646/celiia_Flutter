import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

/// Citations for the daily calorie/macro formulas (App Store 1.4.1).
class NutritionSourcesCitation extends StatelessWidget {
  const NutritionSourcesCitation({
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
      label: 'Mifflin–St Jeor (Am J Clin Nutr, 1990)',
      url: 'https://pubmed.ncbi.nlm.nih.gov/2305711/',
    ),
    (
      label: 'FAO/WHO/UNU physical activity levels',
      url: 'https://www.fao.org/4/y5686e/y5686e07.htm',
    ),
    (
      label: 'ISSN protein position stand',
      url:
          'https://jissn.biomedcentral.com/articles/10.1186/s12970-017-0177-8',
    ),
    (
      label: 'Dietary Guidelines for Americans',
      url: 'https://www.dietaryguidelines.gov/',
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
        color: onDark
            ? Colors.black.withValues(alpha: 0.28)
            : theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.18)
              : theme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nutritionSourcesTitle,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 13 : 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.nutritionSourcesBody,
            style: TextStyle(color: bodyColor, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.nutritionSourcesDisclaimer,
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
