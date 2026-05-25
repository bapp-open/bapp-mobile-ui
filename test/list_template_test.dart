import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/nodes/builtin_nodes.dart';
import 'package:bapp_mobile_ui/src/templates/template_registry.dart';

class FakeApi implements MobileApi {
  FakeApi(this.records);
  final List<Map<String, dynamic>> records;
  String? lastContentType;
  Map<String, dynamic>? lastParams;

  @override
  Future<Map<String, dynamic>> access() async => {'user': {}, 'memberships': []};

  @override
  Future<Map<String, dynamic>> bootstrap(String project) async => {};

  @override
  Future<Map<String, dynamic>> listIntrospect(String ct, String project) async => {};

  @override
  Future<Map<String, dynamic>> detailIntrospect(String ct, String project) async => {};

  @override
  Future<Map<String, dynamic>> screenIntrospect(String key, String project) async => {};

  @override
  Future<List<Map<String, dynamic>>> listRecords(
      String ct, Map<String, dynamic> params) async {
    lastContentType = ct;
    lastParams = params;
    return records;
  }

  @override
  Future<Map<String, dynamic>?> getRecord(String ct, String id) async => null;

  @override
  Future<Map<String, dynamic>?> runAction(
      String code, Map<String, dynamic> payload) async => null;
}

ScreenDef _listScreen() => ScreenDef.fromJson(
    jsonDecode(File('test/fixtures/mobile.listintrospect.passwordentry.json')
            .readAsStringSync()) as Map<String, dynamic>);

void main() {
  testWidgets('list template renders one card per record from the fixture',
      (t) async {
    final api = FakeApi([
      {'name': 'Gmail', 'username': 'a@example.com'},
      {'name': 'GitHub', 'username': 'b@example.com'},
    ]);
    final nodes = NodeRegistry();
    registerBuiltinNodes(nodes);
    final templates = TemplateRegistry();
    registerBuiltinTemplates(templates);
    final screen = _listScreen();

    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (c) => templates.build(c, screen, api, nodes),
        ),
      ),
    ));
    await t.pumpAndSettle();

    expect(api.lastContentType, 'company_passwords.passwordentry');
    expect(api.lastParams!['page_size'], 30);
    expect(find.text('Gmail'), findsOneWidget);
    expect(find.text('a@example.com'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
  });

  testWidgets('empty list shows placeholder', (t) async {
    final nodes = NodeRegistry();
    registerBuiltinNodes(nodes);
    final templates = TemplateRegistry();
    registerBuiltinTemplates(templates);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (c) =>
              templates.build(c, _listScreen(), FakeApi(const []), nodes),
        ),
      ),
    ));
    await t.pumpAndSettle();
    expect(find.text('No items'), findsOneWidget);
  });
}
