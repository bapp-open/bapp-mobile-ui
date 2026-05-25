// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Irish (`ga`).
class AppLocalizationsGa extends AppLocalizations {
  AppLocalizationsGa([String locale = 'ga']) : super(locale);

  @override
  String get chooseTenant => 'Roghnaigh tionónta';

  @override
  String get chooseApp => 'Roghnaigh aip';

  @override
  String get noMobileApps => 'Níl aip soghluaiste ar fáil do do chuntas';

  @override
  String get noScreens => 'Níl scáileáin ann';

  @override
  String get noItems => 'Níl míranna ann';

  @override
  String get save => 'Sábháil';

  @override
  String get done => 'Déanta';

  @override
  String get failed => 'Theip air';

  @override
  String errorWithMessage(String message) {
    return 'Earráid: $message';
  }

  @override
  String get nfcUnavailable => 'NFC nach bhfuil ar fáil';

  @override
  String get online => 'Ar líne';

  @override
  String get offline => 'As líne';
}
