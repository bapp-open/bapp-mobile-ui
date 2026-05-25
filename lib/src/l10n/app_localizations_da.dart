// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get chooseTenant => 'Vælg virksomhed';

  @override
  String get chooseApp => 'Vælg app';

  @override
  String get noMobileApps => 'Ingen mobilapps tilgængelige for din konto';

  @override
  String get noScreens => 'Ingen skærme';

  @override
  String get noItems => 'Ingen elementer';

  @override
  String get save => 'Gem';

  @override
  String get done => 'Færdig';

  @override
  String get failed => 'Mislykkedes';

  @override
  String errorWithMessage(String message) {
    return 'Fejl: $message';
  }

  @override
  String get nfcUnavailable => 'NFC ikke tilgængelig';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
