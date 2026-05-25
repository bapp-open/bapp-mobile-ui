// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get chooseTenant => 'Elegir empresa';

  @override
  String get chooseApp => 'Elegir aplicación';

  @override
  String get noMobileApps =>
      'No hay aplicaciones móviles disponibles para su cuenta';

  @override
  String get noScreens => 'Sin pantallas';

  @override
  String get noItems => 'Sin elementos';

  @override
  String get save => 'Guardar';

  @override
  String get done => 'Hecho';

  @override
  String get failed => 'Error';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get nfcUnavailable => 'NFC no disponible';

  @override
  String get online => 'En línea';

  @override
  String get offline => 'Sin conexión';
}
