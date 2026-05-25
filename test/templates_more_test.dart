import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/project_scope.dart';
import 'package:bapp_mobile_ui/src/render/navigation_dispatcher.dart';
import 'package:bapp_mobile_ui/src/nodes/builtin_nodes.dart';
import 'package:bapp_mobile_ui/src/templates/template_registry.dart';
import 'package:bapp_mobile_ui/src/templates/form_templates.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _f(String n) =>
    jsonDecode(File('test/fixtures/$n').readAsStringSync())
        as Map<String, dynamic>;

NodeRegistry _reg() {
  final r = NodeRegistry();
  registerBuiltinNodes(r);
  return r;
}

TemplateRegistry _templates() {
  final r = TemplateRegistry();
  registerBuiltinTemplates(r);
  return r;
}

/// Wraps [child] in the minimal widget tree needed for template tests.
Widget _host(
  Widget child, {
  String project = 'vault',
  BappNavigateCallback? onNavigate,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ProjectScope(
        project: project,
        child: BappNavigationDispatcher(
          onNavigate: onNavigate ??
              (_, __) async {},
          child: child,
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Fake MobileApi
// ---------------------------------------------------------------------------

class _FakeApi implements MobileApi {
  _FakeApi({Map<String, dynamic>? getSettingsResult})
      : _getSettingsResult = getSettingsResult;

  final Map<String, dynamic>? _getSettingsResult;

  String? lastActionCode;
  Map<String, dynamic>? lastActionPayload;

  @override
  Future<Map<String, dynamic>> access() async =>
      {'user': {}, 'memberships': []};
  @override
  Future<Map<String, dynamic>> bootstrap(String p) async => {};
  @override
  Future<Map<String, dynamic>> listIntrospect(String ct, String p) async => {};
  @override
  Future<Map<String, dynamic>> detailIntrospect(String ct, String p) async =>
      {};
  @override
  Future<Map<String, dynamic>> screenIntrospect(String key, String p) async =>
      {};
  @override
  Future<List<Map<String, dynamic>>> listRecords(
          String ct, Map<String, dynamic> p) async =>
      const [];
  @override
  Future<Map<String, dynamic>?> getRecord(String ct, String id) async => null;

  @override
  Future<Map<String, dynamic>?> runAction(
      String code, Map<String, dynamic> payload) async {
    lastActionCode = code;
    lastActionPayload = Map<String, dynamic>.from(payload);
    if (code == 'mobile.getsettings') {
      return _getSettingsResult ?? {'values': {}};
    }
    return {'success': true, 'message': 'Saved'};
  }
}

// ---------------------------------------------------------------------------
// Dashboard template tests
// ---------------------------------------------------------------------------

void main() {
  group('dashboard template', () {
    testWidgets('renders tile labels from fixture', (t) async {
      final screen = ScreenDef.fromJson(_f('mobile.screen.dashboard.json'));
      final nodes = _reg();
      final templates = _templates();

      await t.pumpWidget(_host(
        Builder(builder: (c) => templates.build(c, screen, _FakeApi(), nodes)),
      ));
      await t.pumpAndSettle();

      expect(find.text('Passwords'), findsOneWidget);
      expect(find.text('Setări'), findsOneWidget);
    });

    testWidgets('tapping a tile calls the navigation dispatcher', (t) async {
      final screen = ScreenDef.fromJson(_f('mobile.screen.dashboard.json'));
      final nodes = _reg();
      final templates = _templates();

      Map<String, dynamic>? capturedOnTap;
      await t.pumpWidget(_host(
        Builder(builder: (c) => templates.build(c, screen, _FakeApi(), nodes)),
        onNavigate: (onTap, _) async {
          capturedOnTap = onTap;
        },
      ));
      await t.pumpAndSettle();

      // Tap the first tile (Passwords)
      await t.tap(find.text('Passwords'));
      await t.pump();

      expect(capturedOnTap, isNotNull);
      expect(capturedOnTap!['screen'],
          equals('company_passwords.passwordentry:list'));
    });
  });

  // -------------------------------------------------------------------------
  // Settings template tests
  // -------------------------------------------------------------------------

  group('settings template', () {
    testWidgets('prefills values from getsettings and reflects them in switches',
        (t) async {
      final screen = ScreenDef.fromJson(_f('mobile.screen.settings.json'));
      final nodes = _reg();
      final api = _FakeApi(
          getSettingsResult: {
            'values': {
              'biometric_unlock': true,
              'hide_passwords': false,
            }
          });

      await t.pumpWidget(_host(
        FormTemplate(screen: screen, api: api, nodes: nodes, settings: true),
      ));
      await t.pumpAndSettle();

      // Both switches should be rendered; biometric_unlock should be on
      final switches = t.widgetList<SwitchListTile>(find.byType(SwitchListTile));
      final biometric =
          switches.firstWhere((s) => (s.title as Text).data == 'Biometric unlock');
      expect(biometric.value, isTrue);

      final hidePasswords = switches
          .firstWhere((s) => (s.title as Text).data == 'Hide passwords by default');
      expect(hidePasswords.value, isFalse);
    });

    testWidgets('toggling switch + tapping Save calls setsettings', (t) async {
      final screen = ScreenDef.fromJson(_f('mobile.screen.settings.json'));
      final nodes = _reg();
      final api = _FakeApi(
          getSettingsResult: {
            'values': {
              'biometric_unlock': false,
              'hide_passwords': false,
            }
          });

      await t.pumpWidget(_host(
        FormTemplate(screen: screen, api: api, nodes: nodes, settings: true),
      ));
      await t.pumpAndSettle();

      // Toggle biometric_unlock on
      await t.tap(find.byType(SwitchListTile).first);
      await t.pump();

      // Tap Save
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();

      expect(api.lastActionCode, equals('mobile.setsettings'));
      expect(api.lastActionPayload!['app'], equals('vault'));
      expect(api.lastActionPayload!['biometric_unlock'], isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Form template tests
  // -------------------------------------------------------------------------

  group('form template', () {
    ScreenDef formScreen() => ScreenDef.fromJson({
          'key': 'test.myform',
          'template': 'form',
          'version': '1',
          'node': {
            'kind': 'column',
            'children': [
              {
                'kind': 'text_input',
                'props': {'name': 'title', 'label': 'Title'},
              },
            ],
          },
          'actions': [
            {'key': 'test.submit', 'label': 'Save', 'kind': 'task', 'submit': true},
          ],
        });

    testWidgets('typing into text_input and tapping Save calls submit action',
        (t) async {
      final screen = formScreen();
      final nodes = _reg();
      final api = _FakeApi();

      await t.pumpWidget(_host(
        FormTemplate(screen: screen, api: api, nodes: nodes),
      ));
      await t.pumpAndSettle();

      // Type into the text field
      await t.enterText(find.byType(TextFormField), 'Hello World');
      await t.pump();

      // Tap Save
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();

      expect(api.lastActionCode, equals('test.submit'));
      expect(api.lastActionPayload!['title'], equals('Hello World'));
    });
  });
}
