// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get chooseTenant => 'Valitse yritys';

  @override
  String get chooseApp => 'Valitse sovellus';

  @override
  String get noMobileApps => 'Tilillesi ei ole saatavilla mobiilisovelluksia';

  @override
  String get noScreens => 'Ei näyttöjä';

  @override
  String get noItems => 'Ei kohteita';

  @override
  String get save => 'Tallenna';

  @override
  String get done => 'Valmis';

  @override
  String get failed => 'Epäonnistui';

  @override
  String errorWithMessage(String message) {
    return 'Virhe: $message';
  }

  @override
  String get nfcUnavailable => 'NFC ei saatavilla';

  @override
  String get online => 'Verkossa';

  @override
  String get offline => 'Yhteydettömässä tilassa';
}
