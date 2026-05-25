// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get chooseTenant => 'Wybierz firmę';

  @override
  String get chooseApp => 'Wybierz aplikację';

  @override
  String get noMobileApps =>
      'Brak dostępnych aplikacji mobilnych dla twojego konta';

  @override
  String get noScreens => 'Brak ekranów';

  @override
  String get noItems => 'Brak elementów';

  @override
  String get save => 'Zapisz';

  @override
  String get done => 'Gotowe';

  @override
  String get failed => 'Niepowodzenie';

  @override
  String errorWithMessage(String message) {
    return 'Błąd: $message';
  }

  @override
  String get nfcUnavailable => 'NFC niedostępny';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
