import 'dart:convert';
import 'dart:io';
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
  // 1. Single app + single tenant → boots straight to nav shell
  // -------------------------------------------------------------------------
  testWidgets('single app + single tenant boots straight to nav shell',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', project: 'vault'),
      apiOverride: _FakeApi(accessResult: _singleMembership()),
    ));
    await t.pumpAndSettle();

    // Should be on the nav shell — list content visible
    expect(find.text('Gmail'), findsOneWidget);
    // No picker shown
    expect(find.byType(AppPicker), findsNothing);
    expect(find.byType(TenantPicker), findsNothing);
  });

  // -------------------------------------------------------------------------
  // 2. config.project null + two apps → AppPicker shown; tapping boots
  // -------------------------------------------------------------------------
  testWidgets('null project + two apps → AppPicker; tap boots chosen app',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      // project intentionally null
      config: const BappMobileConfig(host: 'https://example.test/api'),
      apiOverride: _FakeApi(accessResult: _twoApps()),
    ));
    await t.pumpAndSettle();

    // Both app names visible in picker
    expect(find.text('Vault'), findsOneWidget);
    expect(find.text('CRM'), findsOneWidget);
    expect(find.byType(AppPicker), findsOneWidget);

    // Tap "Vault" (single tenant → auto-selects, boots)
    await t.tap(find.text('Vault'));
    await t.pumpAndSettle();

    // Should now be on the nav shell
    expect(find.text('Gmail'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 3. config.project set + app in two tenants → TenantPicker; tap boots
  // -------------------------------------------------------------------------
  testWidgets('pinned project + two tenants → TenantPicker; tap boots',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', project: 'vault'),
      apiOverride: _FakeApi(accessResult: _twoTenants()),
    ));
    await t.pumpAndSettle();

    // TenantPicker shown
    expect(find.byType(TenantPicker), findsOneWidget);
    expect(find.text('ACME SRL'), findsOneWidget);
    expect(find.text('Beta SRL'), findsOneWidget);

    // Tap first tenant
    await t.tap(find.text('ACME SRL'));
    await t.pumpAndSettle();

    // Nav shell loaded
    expect(find.text('Gmail'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 4. No matching membership → NoAccessView
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
  // Unit tests for AccessInfo pivot helpers
  // -------------------------------------------------------------------------
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

  group('AccessInfo.appsFirst', () {
    test('groups by app slug and collects distinct tenants', () {
      final info = AccessInfo.fromJson(_twoTenants());
      final af = info.appsFirst();
      expect(af.length, 1);
      expect(af.first.app.slug, 'vault');
      expect(af.first.tenants.length, 2);
    });

    test('two different apps each in one tenant → two entries', () {
      final info = AccessInfo.fromJson(_twoApps());
      final af = info.appsFirst();
      expect(af.length, 2);
      expect(af.map((e) => e.app.slug).toSet(), containsAll(['vault', 'crm']));
      for (final e in af) {
        expect(e.tenants.length, 1);
      }
    });

    test('empty memberships → empty list', () {
      final info = AccessInfo.fromJson(_noApps());
      expect(info.appsFirst(), isEmpty);
    });
  });
}
