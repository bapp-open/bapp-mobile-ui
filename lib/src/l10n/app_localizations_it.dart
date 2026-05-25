// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get chooseTenant => 'Scegli azienda';

  @override
  String get chooseApp => 'Scegli applicazione';

  @override
  String get noMobileApps =>
      'Nessuna app mobile disponibile per il tuo account';

  @override
  String get noScreens => 'Nessuna schermata';

  @override
  String get noItems => 'Nessun elemento';

  @override
  String get save => 'Salva';

  @override
  String get done => 'Fatto';

  @override
  String get failed => 'Fallito';

  @override
  String errorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get nfcUnavailable => 'NFC non disponibile';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
