import 'package:calgo/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('mascot dialogue follows every supported app locale', () {
    final vietnamese = lookupAppLocalizations(const Locale('vi'));

    for (final locale in AppLocalizations.supportedLocales) {
      final strings = lookupAppLocalizations(locale);
      final dialogue = <String>[
        strings.mascotGuidanceIntro,
        strings.mascotGuidanceOpen,
        strings.mascotGuidanceTipWater,
        strings.mascotGuidanceTipSlow,
        strings.mascotNoMeals,
      ];

      expect(dialogue.every((line) => line.trim().isNotEmpty), isTrue);
      if (locale.languageCode != 'vi') {
        expect(
            strings.mascotGuidanceIntro, isNot(vietnamese.mascotGuidanceIntro));
        expect(strings.mascotNoMeals, isNot(vietnamese.mascotNoMeals));
      }
    }
  });
}
