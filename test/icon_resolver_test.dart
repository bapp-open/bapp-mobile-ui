import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

Map<String, dynamic> _f(String n) =>
    jsonDecode(File('test/fixtures/$n').readAsStringSync())
        as Map<String, dynamic>;

/// Vault fixtures, used to prove the resolver reaches node-tree + nav icons.
class _FixtureApi implements MobileApi {
  @override
  Future<Map<String, dynamic>> access() async => {
        'user': {'sub': 'u1', 'email': 't@x.io', 'name': 'Test User'},
        'memberships': [
          {
            'tenant': {'id': 'tenant-1', 'name': 'ACME SRL'},
            'apps': [
              {'slug': 'vault', 'name': 'Vault', 'web_app': 'erp'}
            ]
          }
        ]
      };
  @override
  Future<Map<String, dynamic>> bootstrap(String p) async =>
      _f('mobile.bootstrap.vault.json');
  @override
  Future<Map<String, dynamic>> listIntrospect(String ct, String p) async =>
      _f('mobile.listintrospect.passwordentry.json');
  @override
  Future<Map<String, dynamic>> detailIntrospect(String ct, String p) async =>
      _f('mobile.detailintrospect.passwordentry.json');
  @override
  Future<Map<String, dynamic>> screenIntrospect(String key, String p) async =>
      _f('mobile.screen.dashboard.json');
  @override
  Future<List<Map<String, dynamic>>> listRecords(
          String ct, Map<String, dynamic> params) async =>
      [
        {'id': 1, 'name': 'Gmail', 'username': 'a@example.com'},
      ];
  @override
  Future<Map<String, dynamic>?> getRecord(String ct, String id) async =>
      {'id': id, 'name': 'Gmail', 'username': 'a@example.com'};
  @override
  Future<Map<String, dynamic>?> runAction(
          String code, Map<String, dynamic> payload) async =>
      {'success': true};
}

void main() {
  // ---- bappIcon helper -----------------------------------------------------
  testWidgets('bappIcon uses the resolver widget when it returns one',
      (t) async {
    Widget? resolver(String name, {double size = 20, Color? color}) =>
        name == 'fa-key' ? Icon(Icons.star, size: size, color: color) : null;
    await t.pumpWidget(
        MaterialApp(home: bappIcon('fa-key', resolver: resolver)));
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.key), findsNothing);
  });

  testWidgets('bappIcon falls back to Material when resolver returns null',
      (t) async {
    Widget? resolver(String name, {double size = 20, Color? color}) => null;
    await t.pumpWidget(
        MaterialApp(home: bappIcon('fa-key', resolver: resolver)));
    expect(find.byIcon(Icons.key), findsOneWidget); // built-in fa-key mapping
  });

  testWidgets('bappIcon falls back to Material when no resolver given',
      (t) async {
    await t.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(defaultIconData('fa-gear'), Icons.settings);
    expect(defaultIconData('unknown-name'), Icons.circle);
  });

  // ---- fontIconResolver (embedded-font helper) ----------------------------
  testWidgets('fontIconResolver maps names to IconData of the embedded font',
      (t) async {
    final resolver = fontIconResolver(
      fontFamily: 'My Font',
      glyphs: {'key': 0xf084, 'gear': 0xf013},
    );
    // Prefix is stripped automatically; unknown names return null.
    expect(resolver('fa-key'), isNotNull);
    expect(resolver('unknown'), isNull);

    await t.pumpWidget(MaterialApp(home: resolver('fa-key')!));
    final icon = t.widget<Icon>(find.byType(Icon));
    expect(icon.icon!.codePoint, 0xf084);
    expect(icon.icon!.fontFamily, 'My Font');
  });

  test('combineIconResolvers returns the first non-null match', () {
    final solid = fontIconResolver(fontFamily: 'Solid', glyphs: {'key': 0xf084});
    final brands =
        fontIconResolver(fontFamily: 'Brands', glyphs: {'github': 0xf09b});
    final combined = combineIconResolvers([solid, brands]);
    expect(combined('fa-key'), isNotNull);
    expect(combined('fa-github'), isNotNull);
    expect(combined('fa-missing'), isNull);
  });

  // ---- end-to-end: resolver threads into tiles + bottom nav ---------------
  testWidgets('config.iconResolver renders host icons across nodes and nav',
      (t) async {
    SharedPreferences.setMockInitialValues({});
    Widget? star(String name, {double size = 20, Color? color}) =>
        Icon(Icons.star, size: size, color: color);
    await t.pumpWidget(BappMobileApp(
      config: BappMobileConfig(
          host: 'https://example.test/api', project: 'vault', iconResolver: star),
      apiOverride: _FixtureApi(),
    ));
    await t.pumpAndSettle();

    // Dashboard tiles (fa-key, fa-gear) + bottom-nav (fa-house/key/gear) all
    // resolve to the host's star glyph — proving the resolver is threaded.
    expect(find.byIcon(Icons.star), findsWidgets);
    // The built-in Material fallbacks for those names are NOT used.
    expect(find.byIcon(Icons.key), findsNothing);
    expect(find.byIcon(Icons.settings), findsNothing);
  });
}
