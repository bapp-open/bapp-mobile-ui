// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get chooseTenant => 'Escolher empresa';

  @override
  String get chooseApp => 'Escolher aplicação';

  @override
  String get noMobileApps =>
      'Nenhuma aplicação móvel disponível para a sua conta';

  @override
  String get noScreens => 'Sem ecrãs';

  @override
  String get noItems => 'Sem itens';

  @override
  String get save => 'Guardar';

  @override
  String get done => 'Concluído';

  @override
  String get failed => 'Falhou';

  @override
  String errorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get nfcUnavailable => 'NFC indisponível';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';
}
