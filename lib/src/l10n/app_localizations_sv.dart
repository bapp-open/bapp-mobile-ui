// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get chooseTenant => 'Välj företag';

  @override
  String get chooseApp => 'Välj app';

  @override
  String get noMobileApps => 'Inga mobilappar tillgängliga för ditt konto';

  @override
  String get noScreens => 'Inga skärmar';

  @override
  String get noItems => 'Inga objekt';

  @override
  String get save => 'Spara';

  @override
  String get done => 'Klar';

  @override
  String get failed => 'Misslyckades';

  @override
  String errorWithMessage(String message) {
    return 'Fel: $message';
  }

  @override
  String get nfcUnavailable => 'NFC ej tillgänglig';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
