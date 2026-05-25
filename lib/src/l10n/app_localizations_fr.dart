// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get chooseTenant => 'Choisir l\'entreprise';

  @override
  String get chooseApp => 'Choisir l\'application';

  @override
  String get noMobileApps =>
      'Aucune application mobile disponible pour votre compte';

  @override
  String get noScreens => 'Aucun écran';

  @override
  String get noItems => 'Aucun élément';

  @override
  String get save => 'Enregistrer';

  @override
  String get done => 'Terminé';

  @override
  String get failed => 'Échec';

  @override
  String errorWithMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get nfcUnavailable => 'NFC indisponible';

  @override
  String get online => 'En ligne';

  @override
  String get offline => 'Hors ligne';
}
