import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';
import 'package:bapp_mobile_ui/src/models/access.dart';
import 'package:bapp_mobile_ui/src/app/selection_screens.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _f(String n) =>
    jsonDecode(File('test/fixtures/$n').readAsStringSync())
        as Map<String, dynamic>;

/// Single tenant, single app.
Map<String, dynamic> _singleMembership() => {
      'user': {'sub': 'u1', 'email': 't@x.io', 'name': 'Test User'},
      'memberships': [
        {
          'tenant': {'id': 'tenant-1', 'name': 'ACME SRL'},
          'apps': [
            {
              'slug': 'vault',
              'name': 'Vault',
              'icon': 'fa-shield-keyhole',
              'web_app': 'erp'
            }
          ]
        }
      ]
    };

/// Single tenant, two apps.
Map<String, dynamic> _twoApps() => {
      'user': {'sub': 'u1', 'email': 't@x.io', 'name': 'Test User'},
      'memberships': [
        {
          'tenant': {'id': 'tenant-1', 'name': 'ACME SRL'},
          'apps': [
            {'slug': 'vault', 'name': 'Vault', 'web_app': 'erp'},
            {'slug': 'crm', 'name': 'CRM', 'web_app': 'crm'},
          ]
        }
      ]
    };

/// Two tenants, each with the same single app.
Map<String, dynamic> _twoTenants() => {
      'user': {'sub': 'u1', 'email': 't@x.io', 'name': 'Test User'},
      'memberships': [
        {
          'tenant': {'id': 'tenant-1', 'name': 'ACME SRL'},
          'apps': [
            {'slug': 'vault', 'name': 'Vault', 'web_app': 'erp'}
          ]
        },
        {
          'tenant': {'id': 'tenant-2', 'name': 'Beta SRL'},
          'apps': [
            {'slug': 'vault', 'name': 'Vault', 'web_app': 'erp'}
          ]
        },
      ]
    };

/// Two tenants, each offering a DIFFERENT single app (the case that
/// distinguishes app-first from tenant-first routing).
Map<String, dynamic> _appsAcrossTenants() => {
      'user': {'sub': 'u1', 'email': 't@x.io', 'name': 'Test User'},
      'memberships': [
        {
          'tenant': {'id': 'tenant-1', 'name': 'ACME SRL'},
          'apps': [
            {'slug': 'vault', 'name': 'Vault', 'web_app': 'erp'}
          ]
        },
        {
          'tenant': {'id': 'tenant-2', 'name': 'Beta SRL'},
          'apps': [
            {'slug': 'crm', 'name': 'CRM', 'web_app': 'crm'}
          ]
        },
      ]
    };

/// No memberships at all.
Map<String, dynamic> _noApps() => {
      'user': {'sub': 'u1', 'email': 't@x.io', 'name': 'Test User'},
      'memberships': <dynamic>[]
    };

// ---------------------------------------------------------------------------
// Fake API
// ---------------------------------------------------------------------------

class _FakeApi implements MobileApi {
  _FakeApi({required this.accessResult});
  final Map<String, dynamic> accessResult;

  @override
  Future<Map<String, dynamic>> access() async => accessResult;

  @override
  Future<Map<String, dynamic>> bootstrap(String project) async =>
      _f('mobile.bootstrap.vault.json');

  @override
  Future<Map<String, dynamic>> listIntrospect(
          String ct, String project) async =>
      _f('mobile.listintrospect.passwordentry.json');

  @override
  Future<Map<String, dynamic>> detailIntrospect(
          String ct, String project) async =>
      _f('mobile.detailintrospect.passwordentry.json');

  @override
  Future<Map<String, dynamic>> screenIntrospect(
          String key, String project) async =>
      _f('mobile.screen.dashboard.json');

  @override
  Future<List<Map<String, dynamic>>> listRecords(
          String ct, Map<String, dynamic> params) async =>
      [
        {'id': 1, 'name': 'Gmail', 'username': 'a@example.com'},
        {'id': 2, 'name': 'GitHub', 'username': 'b@example.com'},
      ];

  @override
  Future<Map<String, dynamic>?> getRecord(String ct, String id) async =>
      {'id': id, 'name': 'Gmail', 'username': 'a@example.com'};

  @override
  Future<Map<String, dynamic>?> runAction(
          String code, Map<String, dynamic> payload) async =>
      {'success': true, 'message': 'ok'};
}

// ---------------------------------------------------------------------------
// Widget tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // -------------------------------------------------------------------------
  // 1. Single tenant + single app → boots straight to nav shell (no pickers)
  // -------------------------------------------------------------------------
  testWidgets('single tenant + single app boots straight to nav shell',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', project: 'vault'),
      apiOverride: _FakeApi(accessResult: _singleMembership()),
    ));
    await t.pumpAndSettle();

    // Should be on the nav shell — no picker shown
    expect(find.byType(AppPicker), findsNothing);
    expect(find.byType(TenantPicker), findsNothing);

    // First tab is dashboard; tap Passwords bottom-nav item to see list content
    await t.tap(find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Passwords'),
    ));
    await t.pumpAndSettle();
    expect(find.text('Gmail'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 2. Single tenant + 2 apps → AppPicker shown (no TenantPicker); tap boots
  // -------------------------------------------------------------------------
  testWidgets(
      'single tenant + two apps → AppPicker shown (no TenantPicker); tap boots',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      // project intentionally null — full tenant-first flow
      config: const BappMobileConfig(host: 'https://example.test/api'),
      apiOverride: _FakeApi(accessResult: _twoApps()),
    ));
    await t.pumpAndSettle();

    // AppPicker shown, TenantPicker NOT shown (single tenant auto-selected)
    expect(find.byType(AppPicker), findsOneWidget);
    expect(find.byType(TenantPicker), findsNothing);
    expect(find.text('Vault'), findsOneWidget);
    expect(find.text('CRM'), findsOneWidget);

    // Tap "Vault" → boots
    await t.tap(find.text('Vault'));
    await t.pumpAndSettle();

    // Should now be on the nav shell
    await t.tap(find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Passwords'),
    ));
    await t.pumpAndSettle();
    expect(find.text('Gmail'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 3. Two tenants, same single app → single app auto-selected (no AppPicker),
  //    TenantPicker shown; pick → boots
  // -------------------------------------------------------------------------
  testWidgets(
      'two tenants, one app → AppPicker skipped, TenantPicker shown; pick boots',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      // project null — full tenant-first flow
      config: const BappMobileConfig(host: 'https://example.test/api'),
      apiOverride: _FakeApi(accessResult: _twoTenants()),
    ));
    await t.pumpAndSettle();

    // Single app → AppPicker skipped; TenantPicker shown directly
    expect(find.byType(AppPicker), findsNothing);
    expect(find.byType(TenantPicker), findsOneWidget);
    expect(find.text('ACME SRL'), findsOneWidget);
    expect(find.text('Beta SRL'), findsOneWidget);

    // Pick first tenant (has only 1 app → auto-boots)
    await t.tap(find.text('ACME SRL'));
    await t.pumpAndSettle();

    // Nav shell loaded
    await t.tap(find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Passwords'),
    ));
    await t.pumpAndSettle();
    expect(find.text('Gmail'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 4. config.project pinned + that app in 2 tenants → TenantPicker (only
  //    those tenants) → pick → boots that app
  // -------------------------------------------------------------------------
  testWidgets(
      'pinned project + two tenants → TenantPicker (filtered); tap boots',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', project: 'vault'),
      apiOverride: _FakeApi(accessResult: _twoTenants()),
    ));
    await t.pumpAndSettle();

    // TenantPicker shown with both tenants that offer 'vault'
    expect(find.byType(TenantPicker), findsOneWidget);
    expect(find.text('ACME SRL'), findsOneWidget);
    expect(find.text('Beta SRL'), findsOneWidget);

    // Tap first tenant
    await t.tap(find.text('ACME SRL'));
    await t.pumpAndSettle();

    // Nav shell loaded
    await t.tap(find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Passwords'),
    ));
    await t.pumpAndSettle();
    expect(find.text('Gmail'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 5. No membership → NoAccessView
  // -------------------------------------------------------------------------
  testWidgets('no memberships → NoAccessView shown', (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', project: 'vault'),
      apiOverride: _FakeApi(accessResult: _noApps()),
    ));
    await t.pumpAndSettle();

    expect(find.byType(NoAccessView), findsOneWidget);
    expect(
        find.text('No mobile apps available for your account'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 6. Different apps in different tenants → AppPicker FIRST (app-first), then
  //    the chosen app auto-boots its single tenant.
  // -------------------------------------------------------------------------
  testWidgets(
      'different apps per tenant → AppPicker first; pick app → auto-boots its tenant',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(host: 'https://example.test/api'),
      apiOverride: _FakeApi(accessResult: _appsAcrossTenants()),
    ));
    await t.pumpAndSettle();

    // App-first: AppPicker shown before any tenant choice.
    expect(find.byType(AppPicker), findsOneWidget);
    expect(find.byType(TenantPicker), findsNothing);
    expect(find.text('Vault'), findsOneWidget);
    expect(find.text('CRM'), findsOneWidget);

    // Pick "Vault" → it has a single tenant (ACME) → boots without a picker.
    await t.tap(find.text('Vault'));
    await t.pumpAndSettle();
    expect(find.byType(TenantPicker), findsNothing);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 7. allowedApps narrows to a single app → AppPicker skipped entirely.
  //    (A "Vault-only" build off a backend that also exposes CRM.)
  // -------------------------------------------------------------------------
  testWidgets('allowedApps filters to one app → no AppPicker, boots straight',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', allowedApps: ['vault']),
      apiOverride: _FakeApi(accessResult: _twoApps()),
    ));
    await t.pumpAndSettle();

    // CRM was filtered out → single app + single tenant → straight to shell.
    expect(find.byType(AppPicker), findsNothing);
    expect(find.byType(TenantPicker), findsNothing);
    expect(find.text('CRM'), findsNothing);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 8. allowedApps selecting a different app yields a different single-app
  //    build off the same backend/account.
  // -------------------------------------------------------------------------
  testWidgets('allowedApps can pin a different build (crm-only)', (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', allowedApps: ['crm']),
      apiOverride: _FakeApi(accessResult: _appsAcrossTenants()),
    ));
    await t.pumpAndSettle();

    // Only crm is allowed → its single tenant (Beta) auto-boots, no pickers.
    expect(find.byType(AppPicker), findsNothing);
    expect(find.byType(TenantPicker), findsNothing);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // Unit tests for AccessInfo helpers
  // -------------------------------------------------------------------------
  group('AccessInfo.appsFirst', () {
    test('distinct apps each with their offering tenants', () {
      final info = AccessInfo.fromJson(_appsAcrossTenants());
      final af = info.appsFirst();
      expect(af.length, 2);
      final vault = af.firstWhere((e) => e.app.slug == 'vault');
      final crm = af.firstWhere((e) => e.app.slug == 'crm');
      expect(vault.tenants.map((t) => t.id), ['tenant-1']);
      expect(crm.tenants.map((t) => t.id), ['tenant-2']);
    });

    test('same app across tenants collapses to one entry with both tenants', () {
      final info = AccessInfo.fromJson(_twoTenants());
      final af = info.appsFirst();
      expect(af.length, 1);
      expect(af.first.app.slug, 'vault');
      expect(af.first.tenants.map((t) => t.id).toSet(),
          containsAll(['tenant-1', 'tenant-2']));
    });
  });

  group('BappMobileConfig.allowsApp', () {
    test('null allowedApps + no project allows everything', () {
      const c = BappMobileConfig(host: 'h');
      expect(c.allowsApp('vault'), isTrue);
      expect(c.allowsApp('anything'), isTrue);
    });
    test('allowedApps restricts to the listed slugs', () {
      const c = BappMobileConfig(host: 'h', allowedApps: ['vault']);
      expect(c.allowsApp('vault'), isTrue);
      expect(c.allowsApp('crm'), isFalse);
    });
    test('project is a hard pin that overrides allowedApps', () {
      const c =
          BappMobileConfig(host: 'h', project: 'vault', allowedApps: ['crm']);
      expect(c.allowsApp('vault'), isTrue);
      expect(c.allowsApp('crm'), isFalse);
    });
  });

  group('AccessInfo.pairs', () {
    test('returns flat (app, tenant) pairs', () {
      final info = AccessInfo.fromJson(_twoTenants());
      final pairs = info.pairs;
      expect(pairs.length, 2);
      expect(pairs.map((p) => p.tenant.id).toSet(),
          containsAll(['tenant-1', 'tenant-2']));
      expect(pairs.every((p) => p.app.slug == 'vault'), isTrue);
    });
  });

  group('AccessInfo.tenantsFirst', () {
    test('returns one entry per tenant with its apps', () {
      final info = AccessInfo.fromJson(_twoTenants());
      final tf = info.tenantsFirst();
      expect(tf.length, 2);
      expect(tf.map((e) => e.tenant.id).toSet(),
          containsAll(['tenant-1', 'tenant-2']));
      for (final e in tf) {
        expect(e.apps.length, 1);
        expect(e.apps.first.slug, 'vault');
      }
    });

    test('single tenant with two apps → one entry with two apps', () {
      final info = AccessInfo.fromJson(_twoApps());
      final tf = info.tenantsFirst();
      expect(tf.length, 1);
      expect(tf.first.tenant.id, 'tenant-1');
      expect(tf.first.apps.length, 2);
      expect(tf.first.apps.map((a) => a.slug).toSet(),
          containsAll(['vault', 'crm']));
    });

    test('empty memberships → empty list', () {
      final info = AccessInfo.fromJson(_noApps());
      expect(info.tenantsFirst(), isEmpty);
    });
  });
}
