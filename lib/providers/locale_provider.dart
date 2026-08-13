import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/user_facing_error.dart';

/// The language the app is shown in.
///
/// On a fresh install there is no choice to honour, so the app follows the
/// phone: a French handset opens in French, an Arabic one in Arabic, and so
/// on, without asking. Choosing a language in Settings pins it, and that
/// choice then outlives the device changing its own language.
///
/// Unsupported device languages fall back to English.
class LocaleProvider extends ChangeNotifier {
  /// Major world languages with shipped translations.
  ///
  /// Matched by [Locale.languageCode] only, so `fr_CA`, `pt_BR`, `zh_CN`,
  /// `zh_Hans` and similar regional tags all resolve to the right pack.
  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('zh'),
    Locale('hi'),
    Locale('ar'),
    Locale('fr'),
    Locale('pt'),
    Locale('ru'),
    Locale('ja'),
    Locale('de'),
    Locale('ko'),
    Locale('it'),
    Locale('tr'),
    Locale('id'),
    Locale('vi'),
    Locale('th'),
    Locale('pl'),
    Locale('nl'),
  ];

  /// Native endonym shown in the language picker (not translated away).
  static const nativeNames = <String, String>{
    'en': 'English',
    'es': 'Español',
    'zh': '中文',
    'hi': 'हिन्दी',
    'ar': 'العربية',
    'fr': 'Français',
    'pt': 'Português',
    'ru': 'Русский',
    'ja': '日本語',
    'de': 'Deutsch',
    'ko': '한국어',
    'it': 'Italiano',
    'tr': 'Türkçe',
    'id': 'Bahasa Indonesia',
    'vi': 'Tiếng Việt',
    'th': 'ไทย',
    'pl': 'Polski',
    'nl': 'Nederlands',
  };

  static const _prefsKey = 'app_locale';

  /// Null means "follow the device", which is the default and is stored as the
  /// absence of a preference rather than as a value of its own.
  Locale? _locale;
  bool _loaded = false;

  Locale? get locale => _locale;

  /// Whether the app is currently following the phone's language.
  bool get followsDevice => _locale == null;

  /// False until the saved choice has been read, so the first frame can wait
  /// rather than flashing English at a non-English user.
  bool get isLoaded => _loaded;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null && code.isNotEmpty) {
        final matches = supportedLocales
            .where((locale) => locale.languageCode == code)
            .toList();
        _locale = matches.isEmpty ? null : matches.first;
      }
    } catch (_) {
      // A language preference is not worth failing a launch over; following
      // the device is a reasonable answer when storage is unreadable.
    } finally {
      _loaded = true;
      _syncAppLocale();
      notifyListeners();
    }
  }

  /// Pins the app to [locale], or passes null to follow the device again.
  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;
    _locale = locale;
    _syncAppLocale();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_prefsKey);
      } else {
        await prefs.setString(_prefsKey, locale.languageCode);
      }
    } catch (_) {
      // The change still applies for this session even if it cannot be saved.
    }
  }

  /// The language actually in effect, resolving "follow the device" against
  /// [deviceLocales] and falling back to English for anything unsupported.
  Locale effectiveLocale(List<Locale> deviceLocales) {
    final pinned = _locale;
    if (pinned != null) return pinned;

    for (final device in deviceLocales) {
      for (final supported in supportedLocales) {
        if (supported.languageCode == device.languageCode) return supported;
      }
    }
    return const Locale('en');
  }

  /// Keeps provider-side error phrasing on the same language as the widgets.
  void publishEffectiveLocale(List<Locale> deviceLocales) {
    final next = effectiveLocale(deviceLocales);
    if (AppLocale.current == next) return;
    AppLocale.current = next;
  }

  void _syncAppLocale() {
    AppLocale.current = effectiveLocale(
      WidgetsBinding.instance.platformDispatcher.locales,
    );
  }
}
