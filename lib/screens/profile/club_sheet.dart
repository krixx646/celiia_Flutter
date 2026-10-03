import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../services/club_link_service.dart';

/// Explains that the club app is an early version, then opens it in the
/// browser. The wording is deliberate: the link is provisional, and people
/// should know that before they leave Celia.
Future<void> showClubSheet(
  BuildContext context,
  ThemeProvider theme,
  ClubLink link,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.groups_rounded, color: theme.accentOrange, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.clubSheetTitle,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.clubSheetBody,
              style: TextStyle(color: theme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.clubSheetNote,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  final opened = await launchUrl(
                    link.url,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!sheetContext.mounted) return;
                  if (opened) {
                    Navigator.of(sheetContext).pop();
                  } else {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      SnackBar(content: Text(l10n.clubOpenFailed)),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.accentOrange,
                  foregroundColor: Colors.black87,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(
                  l10n.clubOpenButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
