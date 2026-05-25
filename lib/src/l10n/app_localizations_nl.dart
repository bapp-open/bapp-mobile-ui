// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get chooseTenant => 'Kies bedrijf';

  @override
  String get chooseApp => 'Kies app';

  @override
  String get noMobileApps => 'Geen mobiele apps beschikbaar voor uw account';

  @override
  String get noScreens => 'Geen schermen';

  @override
  String get noItems => 'Geen items';

  @override
  String get save => 'Opslaan';

  @override
  String get done => 'Klaar';

  @override
  String get failed => 'Mislukt';

  @override
  String errorWithMessage(String message) {
    return 'Fout: $message';
  }

  @override
  String get nfcUnavailable => 'NFC niet beschikbaar';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
