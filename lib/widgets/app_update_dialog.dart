import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../services/app_update_service.dart';

/// Soft or force prompt; Update starts Play's in-app update flow.
Future<void> showAppUpdateDialog({
  required BuildContext context,
  required ThemeProvider theme,
  required AppUpdatePolicy policy,
  required AppUpdateService service,
}) {
  final force = policy.kind == AppUpdateKind.force;
  return showDialog<void>(
    context: context,
    barrierDismissible: !force,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext);
      return PopScope(
        canPop: !force,
        child: AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            force ? l10n.updateRequiredTitle : l10n.updateAvailableTitle,
            style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            force ? l10n.updateRequiredBody : l10n.updateAvailableBody,
            style: TextStyle(color: theme.textSecondary, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            if (!force)
              TextButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await service.snooze(policy.availableVersionCode);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(l10n.updateLater),
              ),
            FilledButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                final ok = await service.startUpdate(policy);
                if (!dialogContext.mounted) return;
                if (!ok) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(l10n.updateOpenFailed)),
                  );
                  return;
                }
                if (!force) Navigator.of(dialogContext).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.accentOrange,
                foregroundColor: Colors.black87,
                shape: const StadiumBorder(),
              ),
              child: Text(l10n.updateNow),
            ),
          ],
        ),
      );
    },
  );
}

/// Runs after the main shell is up. Failures are silent so a bad network
/// never blocks the home screen. Only Android Play installs report updates.
Future<void> maybePromptAppUpdate(BuildContext context) async {
  try {
    final service = AppUpdateService();
    final policy = await service.check();
    if (!context.mounted || !policy.shouldPrompt) return;
    final theme = context.read<ThemeProvider>();
    await showAppUpdateDialog(
      context: context,
      theme: theme,
      policy: policy,
      service: service,
    );
  } catch (e, st) {
    debugPrint('App update check failed: $e');
    debugPrint('$st');
  }
}
