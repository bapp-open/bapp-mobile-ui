// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get chooseTenant => 'Firma wählen';

  @override
  String get chooseApp => 'App wählen';

  @override
  String get noMobileApps => 'Keine mobilen Apps für Ihr Konto verfügbar';

  @override
  String get noScreens => 'Keine Bildschirme';

  @override
  String get noItems => 'Keine Einträge';

  @override
  String get save => 'Speichern';

  @override
  String get done => 'Fertig';

  @override
  String get failed => 'Fehlgeschlagen';

  @override
  String errorWithMessage(String message) {
    return 'Fehler: $message';
  }

  @override
  String get nfcUnavailable => 'NFC nicht verfügbar';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
