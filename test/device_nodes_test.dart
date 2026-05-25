import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bapp_mobile_ui/src/actions/action_dispatcher.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/record_scope.dart';
import 'package:bapp_mobile_ui/src/render/screen_renderer.dart';
import 'package:bapp_mobile_ui/src/nodes/builtin_nodes.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

NodeRegistry _reg() {
  final r = NodeRegistry();
  registerBuiltinNodes(r); // includes registerDeviceNodes
  return r;
}

Widget _host(Widget child, {Map<String, dynamic>? record}) => MaterialApp(
      home: Scaffold(body: RecordScope(record: record, child: child)),
    );

// ---------------------------------------------------------------------------
// Connectivity channel stubs
//
// connectivity_plus uses two platform channels:
//   - MethodChannel  'dev.fluttercommunity.plus/connectivity'
//   - EventChannel   'dev.fluttercommunity.plus/connectivity_status'
//
// We stub them so the StreamBuilder can build in flutter_test without
// throwing a MissingPluginException.  The widget will show the
// offline/initial state, which is fine — we only assert it renders.
// ---------------------------------------------------------------------------

void _stubConnectivityChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (call) async {
      // checkConnectivity() expects a List of connectivity-result strings.
      if (call.method == 'check') return ['none'];
      return null;
    },
  );

  // Stub the EventChannel stream so the subscription doesn't throw.
  // connectivity_plus registers the event channel as
  // 'dev.fluttercommunity.plus/connectivity_status'.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockStreamHandler(
    const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
    _ConnectivityStreamHandler(),
  );
}

/// A minimal stream handler that immediately sends one 'none' event and
/// never sends more — keeps the StreamBuilder happy without real hardware.
class _ConnectivityStreamHandler extends MockStreamHandler {
  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    // Emit one offline event so the StreamBuilder has data.
    events.success(['none']);
  }

  @override
  void onCancel(Object? arguments) {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Unit test: extended BappActionCallback signature carries extra payload
  // -------------------------------------------------------------------------
  test('BappActionDispatcher onAction receives extra payload', () async {
    Node? gotNode;
    Map<String, dynamic>? gotRecord;
    Map<String, dynamic>? gotExtra;

    // Build a dispatcher whose onAction captures all three arguments.
    final dispatcher = BappActionDispatcher(
      onAction: (n, rec, [extra]) async {
        gotNode = n;
        gotRecord = rec;
        gotExtra = extra;
      },
      child: const SizedBox.shrink(),
    );

    // Extract the callback and invoke it directly with an extra payload.
    const node = Node(kind: 'button', props: {'task': 'warehouse.scan'});
    final record = <String, dynamic>{'id': 42};
    final extra = <String, dynamic>{'code': 'ABC-123'};

    await dispatcher.onAction(node, record, extra);

    expect(gotNode, same(node));
    expect(gotRecord, record);
    expect(gotExtra, extra);
    expect(gotExtra!['code'], 'ABC-123');
  });

  // -------------------------------------------------------------------------
  // scanner-button renders a FilledButton with the label
  // -------------------------------------------------------------------------
  testWidgets('scanner-button renders label as a FilledButton', (t) async {
    await t.pumpWidget(_host(ScreenRenderer(
      registry: _reg(),
      node: const Node(
        kind: 'scanner-button',
        props: {'label': 'Scan barcode'},
      ),
    )));

    expect(find.text('Scan barcode'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    // Icon should be present too.
    expect(find.byIcon(Icons.qr_code_scanner_outlined), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // scanner-button with default label 'Scan'
  // -------------------------------------------------------------------------
  testWidgets('scanner-button uses default label when none provided', (t) async {
    await t.pumpWidget(_host(ScreenRenderer(
      registry: _reg(),
      node: const Node(kind: 'scanner-button', props: {}),
    )));

    expect(find.text('Scan'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // nfc-button renders a FilledButton with the label
  // -------------------------------------------------------------------------
  testWidgets('nfc-button renders label as a FilledButton', (t) async {
    await t.pumpWidget(_host(ScreenRenderer(
      registry: _reg(),
      node: const Node(
        kind: 'nfc-button',
        props: {'label': 'Read NFC'},
      ),
    )));

    expect(find.text('Read NFC'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byIcon(Icons.nfc_outlined), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // nfc-button with default label
  // -------------------------------------------------------------------------
  testWidgets('nfc-button uses default label when none provided', (t) async {
    await t.pumpWidget(_host(ScreenRenderer(
      registry: _reg(),
      node: const Node(kind: 'nfc-button', props: {}),
    )));

    expect(find.text('Read NFC tag'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // connectivity renders without throwing (offline initial state)
  // -------------------------------------------------------------------------
  testWidgets('connectivity node renders a Chip without throwing', (t) async {
    _stubConnectivityChannels();

    await t.pumpWidget(_host(ScreenRenderer(
      registry: _reg(),
      node: const Node(
        kind: 'connectivity',
        props: {
          'online_label': 'Connected',
          'offline_label': 'No network',
        },
      ),
    )));

    // pump once to build initial state, then let async channel calls resolve.
    await t.pump();
    await t.pump(const Duration(milliseconds: 50));

    // The Chip widget must be present (either label is acceptable since this
    // is a test environment with a stubbed 'none' result).
    expect(find.byType(Chip), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // connectivity uses 'Offline' / 'Online' defaults when labels omitted
  // -------------------------------------------------------------------------
  testWidgets('connectivity uses default labels', (t) async {
    _stubConnectivityChannels();

    await t.pumpWidget(_host(ScreenRenderer(
      registry: _reg(),
      node: const Node(kind: 'connectivity', props: {}),
    )));

    await t.pump();
    await t.pump(const Duration(milliseconds: 50));

    // Should find either 'Online' or 'Offline' (both are valid defaults).
    final hasOnline = find.text('Online').evaluate().isNotEmpty;
    final hasOffline = find.text('Offline').evaluate().isNotEmpty;
    expect(hasOnline || hasOffline, isTrue);
  });

  // -------------------------------------------------------------------------
  // nfc-stream renders the prompt card (or unavailable card) without throwing
  // (NFC hardware unavailable in flutter_test — the node must handle this
  //  gracefully via the NfcAvailability probe in initState's post-frame cb)
  // -------------------------------------------------------------------------
  testWidgets('nfc-stream renders without throwing', (t) async {
    // Stub the nfc_manager method channel so checkAvailability returns
    // false (not available) rather than a MissingPluginException.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('nfc_manager'),
      (call) async {
        if (call.method == 'Nfc#isAvailable') return false;
        return null;
      },
    );

    await t.pumpWidget(_host(ScreenRenderer(
      registry: _reg(),
      node: const Node(
        kind: 'nfc-stream',
        props: {'label': 'Scan NFC'},
      ),
    )));

    // First pump builds the initial (probing) state — a Card with a
    // CircularProgressIndicator is shown while the async probe runs.
    await t.pump();
    // Trigger the post-frame callback that fires checkAvailability.
    await t.pump();
    // Allow the stubbed async method-channel call to complete.
    await t.pump(const Duration(milliseconds: 50));

    // The widget tree must contain at least one Card (either the
    // "hold a tag" prompt or the "NFC not available" fallback).
    expect(find.byType(Card), findsWidgets);
  });
}
