import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/render/record_scope.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/screen_renderer.dart';

void main() {
  group('resolveFieldValue', () {
    test('bare name', () => expect(resolveFieldValue('name', {'name': 'x'}), 'x'));
    test('\$field() form',
        () => expect(resolveFieldValue('\$field(name)', {'name': 'x'}), 'x'));
    test('null record', () => expect(resolveFieldValue('name', null), isNull));
    test('missing key',
        () => expect(resolveFieldValue('nope', {'name': 'x'}), isNull));
  });

  testWidgets('registry builds registered kind and falls back for unknown',
      (tester) async {
    final reg = NodeRegistry();
    reg.register('text', (c, n) => Text(n.props['value'] as String));

    // Known kind via ScreenRenderer
    await tester.pumpWidget(MaterialApp(
      home: ScreenRenderer(
          registry: reg,
          node: const Node(kind: 'text', props: {'value': 'hello'})),
    ));
    expect(find.text('hello'), findsOneWidget);

    // Unknown kind falls back gracefully
    await tester.pumpWidget(MaterialApp(
      home: ScreenRenderer(
          registry: reg, node: const Node(kind: 'mystery')),
    ));
    expect(find.text('unsupported: mystery'), findsOneWidget);
  });

  testWidgets('RecordScope.of returns the record', (tester) async {
    Map<String, dynamic>? seen;
    await tester.pumpWidget(MaterialApp(
      home: RecordScope(
        record: const {'name': 'Ada'},
        child: Builder(builder: (c) {
          seen = RecordScope.of(c);
          return const SizedBox();
        }),
      ),
    ));
    expect(seen, {'name': 'Ada'});
  });
}
