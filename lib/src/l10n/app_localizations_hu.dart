// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get chooseTenant => 'Vállalat kiválasztása';

  @override
  String get chooseApp => 'Alkalmazás kiválasztása';

  @override
  String get noMobileApps => 'Nincs elérhető mobilalkalmazás a fiókjához';

  @override
  String get noScreens => 'Nincsenek képernyők';

  @override
  String get noItems => 'Nincsenek elemek';

  @override
  String get save => 'Mentés';

  @override
  String get done => 'Kész';

  @override
  String get failed => 'Sikertelen';

  @override
  String errorWithMessage(String message) {
    return 'Hiba: $message';
  }

  @override
  String get nfcUnavailable => 'NFC nem elérhető';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
