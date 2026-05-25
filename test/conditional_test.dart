import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/record_scope.dart';
import 'package:bapp_mobile_ui/src/render/screen_renderer.dart';
import 'package:bapp_mobile_ui/src/nodes/builtin_nodes.dart';

NodeRegistry _reg() {
  final r = NodeRegistry();
  registerBuiltinNodes(r);
  return r;
}

Widget _host(Widget child, {Map<String, dynamic>? record}) =>
    MaterialApp(home: Scaffold(body: RecordScope(record: record, child: child)));

void main() {
  test('node parses show_when', () {
    final n = Node.fromJson({
      'kind': 'field',
      'props': {'name': 'url', 'widget': 'text'},
      'show_when': {'field': 'url', 'truthy': true},
    });
    expect(n.showWhen, {'field': 'url', 'truthy': true});
  });

  group('evalShowWhen', () {
    test('truthy true shows when value present',
        () => expect(evalShowWhen({'field': 'u', 'truthy': true}, {'u': 'x'}), isTrue));
    test('truthy true hides when empty',
        () => expect(evalShowWhen({'field': 'u', 'truthy': true}, {'u': ''}), isFalse));
    test('equals match',
        () => expect(evalShowWhen({'field': 's', 'equals': 'a'}, {'s': 'a'}), isTrue));
    test('equals mismatch',
        () => expect(evalShowWhen({'field': 's', 'equals': 'a'}, {'s': 'b'}), isFalse));
  });

  testWidgets('show_when hides node when condition false', (t) async {
    const node = Node(
        kind: 'text',
        props: {'value': 'secret'},
        showWhen: {'field': 'u', 'truthy': true});
    await t.pumpWidget(_host(ScreenRenderer(registry: _reg(), node: node),
        record: {'u': ''}));
    expect(find.text('secret'), findsNothing);
  });

  testWidgets('show_when shows node when condition true', (t) async {
    const node = Node(
        kind: 'text',
        props: {'value': 'secret'},
        showWhen: {'field': 'u', 'truthy': true});
    await t.pumpWidget(_host(ScreenRenderer(registry: _reg(), node: node),
        record: {'u': 'present'}));
    expect(find.text('secret'), findsOneWidget);
  });

  testWidgets('tag field maps value to variant label/color', (t) async {
    const node = Node(kind: 'field', props: {
      'name': 'status',
      'widget': 'tag',
      'options': {
        'active': {'label': 'Active', 'color': 'green'},
      },
      'fallback': {'color': 'grey'},
    });
    await t.pumpWidget(_host(ScreenRenderer(registry: _reg(), node: node),
        record: {'status': 'active'}));
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('tag field falls back to raw value when no option matches',
      (t) async {
    const node = Node(kind: 'field', props: {
      'name': 'status',
      'widget': 'tag',
      'options': {
        'active': {'label': 'Active', 'color': 'green'},
      },
      'fallback': {'color': 'grey'},
    });
    await t.pumpWidget(_host(ScreenRenderer(registry: _reg(), node: node),
        record: {'status': 'archived'}));
    expect(find.text('archived'), findsOneWidget);
  });
}
