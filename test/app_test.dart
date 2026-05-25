import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

Map<String, dynamic> _f(String n) =>
    jsonDecode(File('test/fixtures/$n').readAsStringSync()) as Map<String, dynamic>;

class FixtureApi implements MobileApi {
  @override
  Future<Map<String, dynamic>> access() async => {
        'user': {'sub': 'u1', 'email': 't@x.io', 'name': 'Test User'},
        'memberships': [
          {
            'tenant': {'id': 'tenant-1', 'name': 'ACME SRL'},
            'apps': [
              {'slug': 'vault', 'name': 'Vault', 'icon': 'fa-shield-keyhole', 'web_app': 'erp'}
            ]
          }
        ]
      };
  @override
  Future<Map<String, dynamic>> bootstrap(String project) async =>
      _f('mobile.bootstrap.vault.json');
  @override
  Future<Map<String, dynamic>> listIntrospect(String ct, String project) async =>
      _f('mobile.listintrospect.passwordentry.json');
  @override
  Future<Map<String, dynamic>> detailIntrospect(String ct, String project) async =>
      _f('mobile.detailintrospect.passwordentry.json');
  @override
  Future<Map<String, dynamic>> screenIntrospect(String key, String project) async =>
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
      {'id': id, 'name': 'Gmail', 'username': 'a@example.com', 'url': 'https://gmail.com'};
  @override
  Future<Map<String, dynamic>?> runAction(
          String code, Map<String, dynamic> payload) async =>
      {'success': true, 'message': 'ok'};
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('BappMobileApp boots, shows nav + renders list from fixtures',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', project: 'vault'),
      apiOverride: FixtureApi(),
    ));
    await t.pumpAndSettle();

    // First tab is now 'home' (dashboard) — nav bar shows all 3 labels
    expect(find.text('Acasă'), findsWidgets); // app bar title + bottom nav
    // 'Passwords' appears as both a dashboard tile label and a bottom-nav label
    expect(find.text('Passwords'), findsWidgets);
    expect(find.text('Setări'), findsWidgets); // bottom nav label + dashboard tile

    // Tap the 'Passwords' bottom nav item to switch to the list tab
    // Use BottomNavigationBar to find the right target
    await t.tap(find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Passwords'),
    ));
    await t.pumpAndSettle();

    expect(find.text('Gmail'), findsOneWidget);
    expect(find.text('a@example.com'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
  });

  testWidgets('tapping a list card navigates to detail screen', (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', project: 'vault'),
      apiOverride: FixtureApi(),
    ));
    await t.pumpAndSettle();

    // Navigate to the Passwords (list) tab first via the bottom nav bar
    await t.tap(find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Passwords'),
    ));
    await t.pumpAndSettle();

    // List is showing
    expect(find.text('Gmail'), findsOneWidget);

    // Tap the first Card that is a list row (skip tile cards on dashboard)
    await t.tap(find.byType(Card).first);
    await t.pumpAndSettle();

    // Detail screen rendered: AppBar title from fixture is 'Parolă'
    expect(find.text('Parolă'), findsOneWidget);
    // Record field value rendered on detail screen
    expect(find.text('https://gmail.com'), findsOneWidget);
    // Action button visible
    expect(find.text('Dezvăluie parola'), findsOneWidget);
  });
}
