import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';
import 'package:bapp_mobile_ui/src/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Minimal fake API — access() returns no memberships so NoAccessView renders.
// ---------------------------------------------------------------------------

class _NoMembershipApi implements MobileApi {
  @override
  Future<Map<String, dynamic>> access() async => {
        'user': {'sub': 'u1', 'email': 't@x.io', 'name': 'Test'},
        'memberships': <dynamic>[],
      };

  @override
  Future<Map<String, dynamic>> bootstrap(String project) async => {};
  @override
  Future<Map<String, dynamic>> listIntrospect(
          String ct, String project) async =>
      {};
  @override
  Future<Map<String, dynamic>> detailIntrospect(
          String ct, String project) async =>
      {};
  @override
  Future<Map<String, dynamic>> screenIntrospect(
          String key, String project) async =>
      {};
  @override
  Future<List<Map<String, dynamic>>> listRecords(
          String ct, Map<String, dynamic> params) async =>
      [];
  @override
  Future<Map<String, dynamic>?> getRecord(String ct, String id) async => null;
  @override
  Future<Map<String, dynamic>?> runAction(
          String code, Map<String, dynamic> payload) async =>
      null;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // -------------------------------------------------------------------------
  // Widget tests — NoAccessView shows localised no-apps string
  // -------------------------------------------------------------------------

  testWidgets('NoAccessView shows Romanian no-apps text when locale is ro',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
        host: 'https://example.test/api',
        project: 'vault',
        locale: Locale('ro'),
      ),
      apiOverride: _NoMembershipApi(),
    ));
    await t.pumpAndSettle();

    expect(
      find.text('Nicio aplicație mobilă disponibilă pentru contul tău'),
      findsOneWidget,
    );
  });

  testWidgets('NoAccessView shows English no-apps text when locale is en',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
        host: 'https://example.test/api',
        project: 'vault',
        locale: Locale('en'),
      ),
      apiOverride: _NoMembershipApi(),
    ));
    await t.pumpAndSettle();

    expect(
      find.text('No mobile apps available for your account'),
      findsOneWidget,
    );
  });

  // -------------------------------------------------------------------------
  // Delegate unit tests — load AppLocalizations directly for spot-checks
  // -------------------------------------------------------------------------

  testWidgets('AppLocalizations de: save is Speichern', (t) async {
    await t.pumpWidget(
      Localizations(
        locale: const Locale('de'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (ctx) {
            final l10n = AppLocalizations.of(ctx);
            return Text(l10n.save, textDirection: TextDirection.ltr);
          },
        ),
      ),
    );
    await t.pump();
    expect(find.text('Speichern'), findsOneWidget);
  });

  testWidgets('AppLocalizations fr: save is Enregistrer', (t) async {
    await t.pumpWidget(
      Localizations(
        locale: const Locale('fr'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (ctx) {
            final l10n = AppLocalizations.of(ctx);
            return Text(l10n.save, textDirection: TextDirection.ltr);
          },
        ),
      ),
    );
    await t.pump();
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testWidgets('AppLocalizations ro: all keys resolve correctly', (t) async {
    await t.pumpWidget(
      Localizations(
        locale: const Locale('ro'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (ctx) {
            final l10n = AppLocalizations.of(ctx);
            // Verify a sample of keys
            expect(l10n.chooseTenant, 'Alege firma');
            expect(l10n.chooseApp, 'Alege aplicația');
            expect(l10n.save, 'Salvează');
            expect(l10n.done, 'Gata');
            expect(l10n.failed, 'Eșuat');
            expect(l10n.noItems, 'Niciun element');
            expect(l10n.noScreens, 'Niciun ecran');
            expect(l10n.nfcUnavailable, 'NFC indisponibil');
            expect(l10n.online, 'Conectat');
            expect(l10n.offline, 'Deconectat');
            expect(l10n.errorWithMessage('test'), 'Eroare: test');
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await t.pump();
  });

  testWidgets('AppLocalizations en: all keys resolve correctly', (t) async {
    await t.pumpWidget(
      Localizations(
        locale: const Locale('en'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (ctx) {
            final l10n = AppLocalizations.of(ctx);
            expect(l10n.chooseTenant, 'Choose tenant');
            expect(l10n.chooseApp, 'Choose app');
            expect(l10n.save, 'Save');
            expect(l10n.done, 'Done');
            expect(l10n.failed, 'Failed');
            expect(l10n.noItems, 'No items');
            expect(l10n.noScreens, 'No screens');
            expect(l10n.nfcUnavailable, 'NFC unavailable');
            expect(l10n.online, 'Online');
            expect(l10n.offline, 'Offline');
            expect(l10n.errorWithMessage('oops'), 'Error: oops');
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await t.pump();
  });

  testWidgets('AppLocalizations supportedLocales contains all 24 EU locales',
      (t) async {
    const expected = {
      'bg', 'cs', 'da', 'de', 'el', 'en', 'es', 'et', 'fi', 'fr',
      'ga', 'hr', 'hu', 'it', 'lt', 'lv', 'mt', 'nl', 'pl', 'pt',
      'ro', 'sk', 'sl', 'sv',
    };
    final actual =
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    expect(actual, equals(expected));
    addTearDown(() {});
  });
}
