// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get chooseTenant => 'Избери фирма';

  @override
  String get chooseApp => 'Избери приложение';

  @override
  String get noMobileApps => 'Няма налични мобилни приложения за вашия акаунт';

  @override
  String get noScreens => 'Няма екрани';

  @override
  String get noItems => 'Няма елементи';

  @override
  String get save => 'Запази';

  @override
  String get done => 'Готово';

  @override
  String get failed => 'Неуспешно';

  @override
  String errorWithMessage(String message) {
    return 'Грешка: $message';
  }

  @override
  String get nfcUnavailable => 'NFC недостъпен';

  @override
  String get online => 'Онлайн';

  @override
  String get offline => 'Офлайн';
}
