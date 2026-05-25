// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get chooseTenant => 'Vyberte firmu';

  @override
  String get chooseApp => 'Vyberte aplikaci';

  @override
  String get noMobileApps =>
      'Pro váš účet nejsou k dispozici žádné mobilní aplikace';

  @override
  String get noScreens => 'Žádné obrazovky';

  @override
  String get noItems => 'Žádné položky';

  @override
  String get save => 'Uložit';

  @override
  String get done => 'Hotovo';

  @override
  String get failed => 'Nezdařilo se';

  @override
  String errorWithMessage(String message) {
    return 'Chyba: $message';
  }

  @override
  String get nfcUnavailable => 'NFC není dostupné';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
