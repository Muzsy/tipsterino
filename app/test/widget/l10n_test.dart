import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppLocalizations supports English and Hungarian labels', () async {
    final delegate = AppLocalizations.delegate;
    final english = await delegate.load(const Locale('en'));
    final hungarian = await delegate.load(const Locale('hu'));

    expect(english.homeTab, 'Home');
    expect(hungarian.homeTab, 'Kezdőlap');
    expect(english.logoutLabel, 'Log out');
    expect(hungarian.logoutLabel, 'Kijelentkezés');
  });
}
