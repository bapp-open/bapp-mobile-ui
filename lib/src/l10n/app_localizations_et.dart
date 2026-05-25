// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get chooseTenant => 'Vali ettevõte';

  @override
  String get chooseApp => 'Vali rakendus';

  @override
  String get noMobileApps => 'Teie kontole pole mobiilirakendusi saadaval';

  @override
  String get noScreens => 'Ekraane pole';

  @override
  String get noItems => 'Üksusi pole';

  @override
  String get save => 'Salvesta';

  @override
  String get done => 'Valmis';

  @override
  String get failed => 'Ebaõnnestus';

  @override
  String errorWithMessage(String message) {
    return 'Viga: $message';
  }

  @override
  String get nfcUnavailable => 'NFC pole saadaval';

  @override
  String get online => 'Võrgus';

  @override
  String get offline => 'Võrguühenduseta';
}
