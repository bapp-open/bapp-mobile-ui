// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get chooseTenant => 'Pasirinkite įmonę';

  @override
  String get chooseApp => 'Pasirinkite programėlę';

  @override
  String get noMobileApps => 'Jūsų paskyroje nėra mobiliųjų programėlių';

  @override
  String get noScreens => 'Nėra ekranų';

  @override
  String get noItems => 'Nėra elementų';

  @override
  String get save => 'Išsaugoti';

  @override
  String get done => 'Atlikta';

  @override
  String get failed => 'Nepavyko';

  @override
  String errorWithMessage(String message) {
    return 'Klaida: $message';
  }

  @override
  String get nfcUnavailable => 'NFC nepasiekiamas';

  @override
  String get online => 'Prisijungęs';

  @override
  String get offline => 'Atsijungęs';
}
