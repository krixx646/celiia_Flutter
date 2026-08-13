import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';

/// Lets the user override the language the app picked from their phone.
///
/// Fresh installs follow the device. This screen is only for pinning a
/// different major language, or returning to "System default".
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        foregroundColor: theme.textPrimary,
        title: Text(l10n.languageTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _Option(
            theme: theme,
            title: l10n.languageSystem,
            subtitle: l10n.languageSystemSubtitle,
            selected: localeProvider.followsDevice,
            onTap: () => localeProvider.setLocale(null),
          ),
          const SizedBox(height: 16),
          for (final locale in LocaleProvider.supportedLocales) ...[
            _Option(
              theme: theme,
              title: LocaleProvider.nativeNames[locale.languageCode] ??
                  locale.languageCode,
              subtitle: locale.languageCode.toUpperCase(),
              selected: !localeProvider.followsDevice &&
                  localeProvider.locale?.languageCode == locale.languageCode,
              onTap: () => localeProvider.setLocale(locale),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final ThemeProvider theme;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.accentOrange : theme.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: theme.textSecondary),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: theme.accentOrange),
          ],
        ),
      ),
    );
  }
}
