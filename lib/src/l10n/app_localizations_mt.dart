// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Maltese (`mt`).
class AppLocalizationsMt extends AppLocalizations {
  AppLocalizationsMt([String locale = 'mt']) : super(locale);

  @override
  String get chooseTenant => 'Agħżel kumpanija';

  @override
  String get chooseApp => 'Agħżel applikazzjoni';

  @override
  String get noMobileApps =>
      'L-ebda applikazzjonijiet mobbli disponibbli għall-kont tiegħek';

  @override
  String get noScreens => 'L-ebda skrin';

  @override
  String get noItems => 'L-ebda elementi';

  @override
  String get save => 'Issejvja';

  @override
  String get done => 'Lest';

  @override
  String get failed => 'Falliet';

  @override
  String errorWithMessage(String message) {
    return 'Żball: $message';
  }

  @override
  String get nfcUnavailable => 'NFC mhux disponibbli';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
