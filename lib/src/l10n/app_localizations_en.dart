// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get chooseTenant => 'Choose tenant';

  @override
  String get chooseApp => 'Choose app';

  @override
  String get noMobileApps => 'No mobile apps available for your account';

  @override
  String get noScreens => 'No screens';

  @override
  String get noItems => 'No items';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get failed => 'Failed';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get nfcUnavailable => 'NFC unavailable';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
