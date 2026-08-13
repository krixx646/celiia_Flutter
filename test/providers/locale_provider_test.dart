import 'package:celia_flutter/providers/locale_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('following the device', () {
    test('a fresh install opens in the phone\'s language', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();
      await provider.load();

      expect(provider.followsDevice, isTrue);
      expect(
        provider.effectiveLocale([const Locale('fr', 'FR')]),
        const Locale('fr'),
      );
      expect(
        provider.effectiveLocale([const Locale('zh', 'CN')]),
        const Locale('zh'),
      );
    });

    test('a language the app does not speak falls back to English', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();
      await provider.load();

      expect(
        provider.effectiveLocale([
          const Locale('sw'), // Swahili — not shipped yet
          const Locale('bn'), // Bengali — not shipped yet
        ]),
        const Locale('en'),
      );
    });

    test('takes the first device language the app does speak', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();
      await provider.load();

      expect(
        provider.effectiveLocale([
          const Locale('sw'),
          const Locale('de'),
          const Locale('es'),
        ]),
        const Locale('de'),
      );
    });
  });

  group('a chosen language', () {
    test('is remembered across launches', () async {
      SharedPreferences.setMockInitialValues({});
      final first = LocaleProvider();
      await first.load();
      await first.setLocale(const Locale('ja'));

      final second = LocaleProvider();
      await second.load();

      expect(second.locale, const Locale('ja'));
      expect(second.followsDevice, isFalse);
    });

    test('outranks the device, which is the point of choosing it', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final provider = LocaleProvider();
      await provider.load();

      expect(
        provider.effectiveLocale([const Locale('es')]),
        const Locale('en'),
      );
    });

    test('can be handed back to the device', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'es'});
      final provider = LocaleProvider();
      await provider.load();
      await provider.setLocale(null);

      final reopened = LocaleProvider();
      await reopened.load();

      expect(reopened.followsDevice, isTrue);
    });
  });

  test('every supported language is one the app has translations for', () {
    expect(
      LocaleProvider.supportedLocales.map((l) => l.languageCode).toSet(),
      LocaleProvider.nativeNames.keys.toSet(),
    );
    expect(LocaleProvider.supportedLocales, hasLength(18));
  });
}
