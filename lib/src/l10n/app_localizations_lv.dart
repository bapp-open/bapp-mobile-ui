// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get chooseTenant => 'Izvēlēties uzņēmumu';

  @override
  String get chooseApp => 'Izvēlēties lietotni';

  @override
  String get noMobileApps => 'Jūsu kontam nav pieejamu mobilo lietotņu';

  @override
  String get noScreens => 'Nav ekrānu';

  @override
  String get noItems => 'Nav elementu';

  @override
  String get save => 'Saglabāt';

  @override
  String get done => 'Gatavs';

  @override
  String get failed => 'Neizdevās';

  @override
  String errorWithMessage(String message) {
    return 'Kļūda: $message';
  }

  @override
  String get nfcUnavailable => 'NFC nav pieejams';

  @override
  String get online => 'Tiešsaistē';

  @override
  String get offline => 'Bezsaistē';
}
