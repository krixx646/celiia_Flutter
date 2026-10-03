import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppUpdateKind { none, soft, force }

class AppUpdatePolicy {
  const AppUpdatePolicy({
    required this.kind,
    required this.availableVersionCode,
    required this.immediateAllowed,
    required this.flexibleAllowed,
  });

  final AppUpdateKind kind;
  final int availableVersionCode;
  final bool immediateAllowed;
  final bool flexibleAllowed;

  bool get shouldPrompt => kind != AppUpdateKind.none;
}

/// Asks Play Store whether a newer build is published, then decides whether
/// to prompt. No backend version list — Play is the source of truth.
class AppUpdateService {
  AppUpdateService({
    Future<AppUpdateInfo> Function()? checkForUpdate,
    Future<AppUpdateResult> Function()? performImmediateUpdate,
    Future<AppUpdateResult> Function()? startFlexibleUpdate,
    Future<void> Function()? completeFlexibleUpdate,
    Future<SharedPreferences> Function()? prefsLoader,
  }) : _checkForUpdate = checkForUpdate ?? InAppUpdate.checkForUpdate,
       _performImmediateUpdate =
           performImmediateUpdate ?? InAppUpdate.performImmediateUpdate,
       _startFlexibleUpdate =
           startFlexibleUpdate ?? InAppUpdate.startFlexibleUpdate,
       _completeFlexibleUpdate =
           completeFlexibleUpdate ?? InAppUpdate.completeFlexibleUpdate,
       _prefsLoader = prefsLoader ?? SharedPreferences.getInstance;

  final Future<AppUpdateInfo> Function() _checkForUpdate;
  final Future<AppUpdateResult> Function() _performImmediateUpdate;
  final Future<AppUpdateResult> Function() _startFlexibleUpdate;
  final Future<void> Function() _completeFlexibleUpdate;
  final Future<SharedPreferences> Function() _prefsLoader;

  static const Duration snoozeDuration = Duration(days: 3);
  static const String _snoozeUntilKey = 'app_update_snooze_until_ms';
  static const String _snoozeVersionKey = 'app_update_snooze_version_code';

  /// Google treats priority 4–5 as urgent enough for an immediate (blocking) flow.
  static const int forcePriorityThreshold = 4;

  Future<AppUpdatePolicy> check() async {
    if (kIsWeb || !Platform.isAndroid) {
      return const AppUpdatePolicy(
        kind: AppUpdateKind.none,
        availableVersionCode: 0,
        immediateAllowed: false,
        flexibleAllowed: false,
      );
    }

    final info = await _checkForUpdate();
    final versionCode = info.availableVersionCode ?? 0;
    if (info.updateAvailability != UpdateAvailability.updateAvailable) {
      return AppUpdatePolicy(
        kind: AppUpdateKind.none,
        availableVersionCode: versionCode,
        immediateAllowed: info.immediateUpdateAllowed,
        flexibleAllowed: info.flexibleUpdateAllowed,
      );
    }

    final force =
        info.updatePriority >= forcePriorityThreshold &&
        info.immediateUpdateAllowed;

    if (!force && await _isSnoozed(versionCode)) {
      return AppUpdatePolicy(
        kind: AppUpdateKind.none,
        availableVersionCode: versionCode,
        immediateAllowed: info.immediateUpdateAllowed,
        flexibleAllowed: info.flexibleUpdateAllowed,
      );
    }

    return AppUpdatePolicy(
      kind: force ? AppUpdateKind.force : AppUpdateKind.soft,
      availableVersionCode: versionCode,
      immediateAllowed: info.immediateUpdateAllowed,
      flexibleAllowed: info.flexibleUpdateAllowed,
    );
  }

  Future<void> snooze(int availableVersionCode) async {
    final prefs = await _prefsLoader();
    final until = DateTime.now().add(snoozeDuration).millisecondsSinceEpoch;
    await prefs.setInt(_snoozeUntilKey, until);
    await prefs.setInt(_snoozeVersionKey, availableVersionCode);
  }

  /// Starts Play's in-app update UI. Soft updates prefer a background download;
  /// force updates use the full-screen immediate flow when Play allows it.
  Future<bool> startUpdate(AppUpdatePolicy policy) async {
    if (policy.kind == AppUpdateKind.force && policy.immediateAllowed) {
      final result = await _performImmediateUpdate();
      return result == AppUpdateResult.success;
    }
    if (policy.flexibleAllowed) {
      final result = await _startFlexibleUpdate();
      if (result == AppUpdateResult.success) {
        await _completeFlexibleUpdate();
        return true;
      }
      return false;
    }
    if (policy.immediateAllowed) {
      final result = await _performImmediateUpdate();
      return result == AppUpdateResult.success;
    }
    return false;
  }

  Future<bool> _isSnoozed(int availableVersionCode) async {
    final prefs = await _prefsLoader();
    final untilMs = prefs.getInt(_snoozeUntilKey);
    final snoozedCode = prefs.getInt(_snoozeVersionKey);
    if (untilMs == null || snoozedCode == null) return false;
    if (snoozedCode != availableVersionCode) return false;
    return DateTime.now().millisecondsSinceEpoch < untilMs;
  }
}
