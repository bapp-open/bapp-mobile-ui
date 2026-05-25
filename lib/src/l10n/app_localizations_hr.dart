// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get chooseTenant => 'Odaberi tvrtku';

  @override
  String get chooseApp => 'Odaberi aplikaciju';

  @override
  String get noMobileApps => 'Nema dostupnih mobilnih aplikacija za vaš račun';

  @override
  String get noScreens => 'Nema zaslona';

  @override
  String get noItems => 'Nema stavki';

  @override
  String get save => 'Spremi';

  @override
  String get done => 'Gotovo';

  @override
  String get failed => 'Neuspješno';

  @override
  String errorWithMessage(String message) {
    return 'Pogreška: $message';
  }

  @override
  String get nfcUnavailable => 'NFC nedostupan';

  @override
  String get online => 'Na mreži';

  @override
  String get offline => 'Izvan mreže';
}
