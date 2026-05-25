import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/actions/action_runner.dart';
import 'package:bapp_mobile_ui/src/actions/action_dispatcher.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/record_scope.dart';
import 'package:bapp_mobile_ui/src/render/screen_renderer.dart';
import 'package:bapp_mobile_ui/src/nodes/builtin_nodes.dart';

class FakeApi implements MobileApi {
  FakeApi(this.response);
  final Map<String, dynamic>? response;
  String? lastCode;
  Map<String, dynamic>? lastPayload;
  @override
  Future<Map<String, dynamic>> bootstrap(String p) async => {};
  @override
  Future<Map<String, dynamic>> listIntrospect(String c, String p) async => {};
  @override
  Future<Map<String, dynamic>> detailIntrospect(String c, String p) async => {};
  @override
  Future<List<Map<String, dynamic>>> listRecords(String c, Map<String, dynamic> p) async => const [];
  @override
  Future<Map<String, dynamic>?> getRecord(String c, String id) async => null;
  @override
  Future<Map<String, dynamic>?> runAction(String code, Map<String, dynamic> payload) async {
    lastCode = code;
    lastPayload = payload;
    return response;
  }
}

void main() {
  test('ActionRunner parses message + invalidates (list-of-list)', () async {
    final api = FakeApi({
      'success': true,
      'message': 'Done',
      'invalidates': [
        ['company_passwords.passwordentry', {}]
      ],
    });
    final result = await ActionRunner(api).run('company_passwords.revealpassword', {'pk': 1});
    expect(api.lastCode, 'company_passwords.revealpassword');
    expect(api.lastPayload, {'pk': 1});
    expect(result.success, isTrue);
    expect(result.message, 'Done');
    expect(result.invalidates, contains('company_passwords.passwordentry'));
  });

  test('ActionResult handles null response', () {
    final r = ActionResult.fromResponse(null);
    expect(r.success, isTrue);
    expect(r.invalidates, isEmpty);
  });

  testWidgets('button dispatches the node + record on tap', (t) async {
    Node? gotNode;
    Map<String, dynamic>? gotRecord;
    final nodes = NodeRegistry();
    registerBuiltinNodes(nodes);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BappActionDispatcher(
          onAction: (n, rec) async {
            gotNode = n;
            gotRecord = rec;
          },
          child: RecordScope(
            record: const {'id': 7},
            child: Builder(
              builder: (c) => ScreenRenderer(
                registry: nodes,
                node: const Node(kind: 'button', props: {'label': 'Confirm', 'kind': 'task', 'task': 'x.do'}),
              ),
            ),
          ),
        ),
      ),
    ));
    await t.tap(find.byType(FilledButton));
    await t.pump();
    expect(gotNode!.props['task'], 'x.do');
    expect(gotRecord, {'id': 7});
  });
}
