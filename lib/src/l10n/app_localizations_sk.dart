// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get chooseTenant => 'Vyberte firmu';

  @override
  String get chooseApp => 'Vyberte aplikáciu';

  @override
  String get noMobileApps =>
      'Pre váš účet nie sú k dispozícii žiadne mobilné aplikácie';

  @override
  String get noScreens => 'Žiadne obrazovky';

  @override
  String get noItems => 'Žiadne položky';

  @override
  String get save => 'Uložiť';

  @override
  String get done => 'Hotovo';

  @override
  String get failed => 'Zlyhalo';

  @override
  String errorWithMessage(String message) {
    return 'Chyba: $message';
  }

  @override
  String get nfcUnavailable => 'NFC nie je dostupné';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
