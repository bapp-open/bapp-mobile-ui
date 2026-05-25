// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get chooseTenant => 'Izberi podjetje';

  @override
  String get chooseApp => 'Izberi aplikacijo';

  @override
  String get noMobileApps =>
      'Za vaš račun ni na voljo nobenih mobilnih aplikacij';

  @override
  String get noScreens => 'Ni zaslonov';

  @override
  String get noItems => 'Ni elementov';

  @override
  String get save => 'Shrani';

  @override
  String get done => 'Končano';

  @override
  String get failed => 'Neuspešno';

  @override
  String errorWithMessage(String message) {
    return 'Napaka: $message';
  }

  @override
  String get nfcUnavailable => 'NFC ni na voljo';

  @override
  String get online => 'V omrežju';

  @override
  String get offline => 'Brez povezave';
}
