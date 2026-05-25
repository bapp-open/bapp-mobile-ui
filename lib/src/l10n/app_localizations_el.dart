// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get chooseTenant => 'Επιλογή εταιρείας';

  @override
  String get chooseApp => 'Επιλογή εφαρμογής';

  @override
  String get noMobileApps =>
      'Δεν υπάρχουν διαθέσιμες εφαρμογές για τον λογαριασμό σας';

  @override
  String get noScreens => 'Δεν υπάρχουν οθόνες';

  @override
  String get noItems => 'Δεν υπάρχουν στοιχεία';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get done => 'Τέλος';

  @override
  String get failed => 'Αποτυχία';

  @override
  String errorWithMessage(String message) {
    return 'Σφάλμα: $message';
  }

  @override
  String get nfcUnavailable => 'NFC μη διαθέσιμο';

  @override
  String get online => 'Συνδεδεμένος';

  @override
  String get offline => 'Αποσυνδεδεμένος';
}
