import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/nodes/builtin_nodes.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/screens/detail_screen_view.dart';

Map<String, dynamic> _f(String n) =>
    jsonDecode(File('test/fixtures/$n').readAsStringSync())
        as Map<String, dynamic>;

class FakeDetailApi implements MobileApi {
  @override
  Future<Map<String, dynamic>> access() async => {'user': {}, 'memberships': []};
  @override
  Future<Map<String, dynamic>> bootstrap(String project) async => {};
  @override
  Future<Map<String, dynamic>> listIntrospect(String ct, String p) async => {};
  @override
  Future<Map<String, dynamic>> detailIntrospect(String ct, String p) async =>
      _f('mobile.detailintrospect.passwordentry.json');
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

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('DetailScreenView renders fields and action button', (t) async {
    final nodes = NodeRegistry();
    registerBuiltinNodes(nodes);

    await t.pumpWidget(MaterialApp(
      home: DetailScreenView(
        api: FakeDetailApi(),
        nodes: nodes,
        project: 'vault',
        screenKey: 'company_passwords.passwordentry:detail',
        recordId: '1',
      ),
    ));
    await t.pumpAndSettle();

    // Field values rendered
    expect(find.text('Gmail'), findsOneWidget);
    expect(find.text('a@x.io'), findsOneWidget);

    // Action button rendered (from the fixture's actions list)
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('Dezvăluie parola'), findsOneWidget);
  });
}
