// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get chooseTenant => 'Alege firma';

  @override
  String get chooseApp => 'Alege aplicația';

  @override
  String get noMobileApps =>
      'Nicio aplicație mobilă disponibilă pentru contul tău';

  @override
  String get noScreens => 'Niciun ecran';

  @override
  String get noItems => 'Niciun element';

  @override
  String get save => 'Salvează';

  @override
  String get done => 'Gata';

  @override
  String get failed => 'Eșuat';

  @override
  String errorWithMessage(String message) {
    return 'Eroare: $message';
  }

  @override
  String get nfcUnavailable => 'NFC indisponibil';

  @override
  String get online => 'Conectat';

  @override
  String get offline => 'Deconectat';
}
