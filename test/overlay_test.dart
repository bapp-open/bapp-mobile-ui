import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';
import 'package:bapp_mobile_ui/src/nodes/builtin_nodes.dart';
import 'package:bapp_mobile_ui/src/render/navigation_dispatcher.dart';
import 'package:bapp_mobile_ui/src/render/overlay.dart';
import 'package:bapp_mobile_ui/src/render/screen_renderer.dart';

// ---------------------------------------------------------------------------
// Shared fixture loader
// ---------------------------------------------------------------------------

Map<String, dynamic> _f(String n) =>
    jsonDecode(File('test/fixtures/$n').readAsStringSync())
        as Map<String, dynamic>;

// ---------------------------------------------------------------------------
// Minimal MobileApi fake for overlay tests
// ---------------------------------------------------------------------------

class _FakeApi implements MobileApi {
  @override
  Future<Map<String, dynamic>> access() async =>
      {'user': {}, 'memberships': []};
  @override
  Future<Map<String, dynamic>> bootstrap(String p) async => {};
  @override
  Future<Map<String, dynamic>> listIntrospect(String ct, String p) async => {};
  @override
  Future<Map<String, dynamic>> detailIntrospect(String ct, String p) async =>
      _f('mobile.detailintrospect.passwordentry.json');
  @override
  Future<Map<String, dynamic>> screenIntrospect(String key, String p) async =>
      _f('mobile.screen.dashboard.json');
  @override
  Future<List<Map<String, dynamic>>> listRecords(
          String ct, Map<String, dynamic> params) async =>
      const [];
  @override
  Future<Map<String, dynamic>?> getRecord(String ct, String id) async =>
      {'id': id, 'name': 'Gmail', 'username': 'a@x.io', 'url': 'http://x'};
  @override
  Future<Map<String, dynamic>?> runAction(
          String code, Map<String, dynamic> payload) async =>
      {'success': true, 'message': 'ok'};
}

// ---------------------------------------------------------------------------
// FixtureApi reused for end-to-end BappMobileApp test
// ---------------------------------------------------------------------------

class _FullFixtureApi implements MobileApi {
  @override
  Future<Map<String, dynamic>> access() async => {
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
  Future<Map<String, dynamic>?> getRecord(String ct, String id) async => {
        'id': id,
        'name': 'Gmail',
        'username': 'a@example.com',
        'url': 'https://gmail.com'
      };
  @override
  Future<Map<String, dynamic>?> runAction(
          String code, Map<String, dynamic> payload) async =>
      {'success': true, 'message': 'ok'};
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // ------------------------------------------------------------------
  // Focused: showPresentOverlay shows inline node content in a sheet
  // ------------------------------------------------------------------
  testWidgets('showPresentOverlay shows inline node in bottom sheet', (t) async {
    final nodes = NodeRegistry();
    registerBuiltinNodes(nodes);
    final api = _FakeApi();

    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showPresentOverlay(
              ctx,
              {
                'present': 'sheet',
                'node': {
                  'kind': 'text',
                  'props': {'value': 'hello-overlay'},
                },
              },
              null,
              api: api,
              nodes: nodes,
              project: 'vault',
              onAction: (code, rec) async {},
              onNavigate: (onTap, rec) async {},
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));

    await t.tap(find.text('Open'));
    await t.pumpAndSettle();

    expect(find.text('hello-overlay'), findsOneWidget);
  });

  // ------------------------------------------------------------------
  // Focused: showPresentOverlay with mode='dialog'
  // ------------------------------------------------------------------
  testWidgets('showPresentOverlay shows inline node in dialog', (t) async {
    final nodes = NodeRegistry();
    registerBuiltinNodes(nodes);
    final api = _FakeApi();

    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showPresentOverlay(
              ctx,
              {
                'present': 'dialog',
                'node': {
                  'kind': 'text',
                  'props': {'value': 'dialog-content'},
                },
              },
              null,
              api: api,
              nodes: nodes,
              project: 'vault',
              onAction: (code, rec) async {},
              onNavigate: (onTap, rec) async {},
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));

    await t.tap(find.text('Open'));
    await t.pumpAndSettle();

    expect(find.text('dialog-content'), findsOneWidget);
  });

  // ------------------------------------------------------------------
  // Focused: action menu renders list tiles and fires onAction on tap
  // ------------------------------------------------------------------
  testWidgets('showPresentOverlay action menu fires onAction', (t) async {
    final nodes = NodeRegistry();
    registerBuiltinNodes(nodes);
    final api = _FakeApi();
    String? firedCode;

    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showPresentOverlay(
              ctx,
              {
                'present': 'sheet',
                'actions': [
                  {'key': 'do.thing', 'label': 'Do Thing'},
                ],
              },
              null,
              api: api,
              nodes: nodes,
              project: 'vault',
              onAction: (code, rec) async { firedCode = code; },
              onNavigate: (onTap, rec) async {},
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));

    await t.tap(find.text('Open'));
    await t.pumpAndSettle();

    expect(find.text('Do Thing'), findsOneWidget);
    await t.tap(find.text('Do Thing'));
    await t.pumpAndSettle();

    expect(firedCode, 'do.thing');
  });

  // ------------------------------------------------------------------
  // icon node renders Icons.info_outline for 'fa-circle-info'
  // ------------------------------------------------------------------
  testWidgets('icon node renders info_outline icon', (t) async {
    final nodes = NodeRegistry();
    registerBuiltinNodes(nodes);

    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ScreenRenderer(
          registry: nodes,
          node: const Node(
            kind: 'icon',
            props: {'icon': 'fa-circle-info'},
          ),
        ),
      ),
    ));

    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  // ------------------------------------------------------------------
  // icon node with on_tap calls navigation dispatcher
  // ------------------------------------------------------------------
  testWidgets('icon node with on_tap invokes navigation dispatcher', (t) async {
    final nodes = NodeRegistry();
    registerBuiltinNodes(nodes);
    Map<String, dynamic>? navigatedTo;

    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BappNavigationDispatcher(
          onNavigate: (onTap, rec) async { navigatedTo = onTap; },
          child: ScreenRenderer(
            registry: nodes,
            node: const Node(
              kind: 'icon',
              props: {'icon': 'fa-circle-info'},
              onTap: {'present': 'sheet', 'node': {'kind': 'text', 'props': {'value': 'x'}}},
            ),
          ),
        ),
      ),
    ));

    await t.tap(find.byIcon(Icons.info_outline));
    await t.pumpAndSettle();

    expect(navigatedTo, isNotNull);
    expect(navigatedTo!['present'], 'sheet');
  });

  // ------------------------------------------------------------------
  // End-to-end: boot app → Passwords tab → detail → info icon → sheet
  // ------------------------------------------------------------------
  testWidgets(
      'end-to-end: detail info icon opens sheet with Quick actions + Reveal button',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', project: 'vault'),
      apiOverride: _FullFixtureApi(),
    ));
    await t.pumpAndSettle();

    // Navigate to Passwords list tab
    await t.tap(find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Passwords'),
    ));
    await t.pumpAndSettle();

    // Tap first card to open detail
    expect(find.text('Gmail'), findsOneWidget);
    await t.tap(find.byType(Card).first);
    await t.pumpAndSettle();

    // Detail screen is showing
    expect(find.text('Parolă'), findsOneWidget);

    // The info icon should be visible (fa-circle-info → Icons.info_outline)
    expect(find.byIcon(Icons.info_outline), findsOneWidget);

    // Tap the icon to open the sheet
    await t.tap(find.byIcon(Icons.info_outline));
    await t.pumpAndSettle();

    // Sheet content: 'Quick actions' text and 'Reveal' button
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Reveal'), findsOneWidget);
  });
}
