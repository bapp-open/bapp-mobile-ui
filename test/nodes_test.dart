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

Widget _host(Widget child, {Map<String, dynamic>? record}) => MaterialApp(
      home: Scaffold(body: RecordScope(record: record, child: child)),
    );

void main() {
  testWidgets('text node renders value', (t) async {
    await t.pumpWidget(_host(ScreenRenderer(
        registry: _reg(), node: const Node(kind: 'text', props: {'value': 'hi'}))));
    expect(find.text('hi'), findsOneWidget);
  });

  testWidgets('field title resolves from record', (t) async {
    await t.pumpWidget(_host(
      ScreenRenderer(
          registry: _reg(),
          node: const Node(kind: 'field', props: {'name': 'name', 'widget': 'title'})),
      record: {'name': 'Ada'},
    ));
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('card renders its field children', (t) async {
    const card = Node(kind: 'card', children: [
      Node(kind: 'field', props: {'name': 'name', 'widget': 'title'}),
      Node(kind: 'field', props: {'name': 'username', 'widget': 'subtitle'}),
    ]);
    await t.pumpWidget(_host(ScreenRenderer(registry: _reg(), node: card),
        record: {'name': 'Ada', 'username': 'ada@x.io'}));
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('ada@x.io'), findsOneWidget);
  });

  testWidgets('button renders label as FilledButton', (t) async {
    await t.pumpWidget(_host(ScreenRenderer(
        registry: _reg(), node: const Node(kind: 'button', props: {'label': 'Confirm'}))));
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
