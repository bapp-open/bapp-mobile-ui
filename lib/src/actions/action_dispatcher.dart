import 'package:flutter/widgets.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';

/// Provides an action callback to descendant button nodes. The app supplies the
/// callback (which uses ActionRunner + applies the result).
///
/// The optional [extra] map carries device-scan payloads (e.g. `{'code': '…'}`
/// for scanner nodes, `{'tag': '…'}` for NFC nodes) that are merged into the
/// task payload before it is sent to the server.  Regular button nodes pass
/// nothing for [extra] (it defaults to null, which is a no-op).
typedef BappActionCallback = Future<void> Function(
    Node button, Map<String, dynamic>? record,
    [Map<String, dynamic>? extra]);

class BappActionDispatcher extends InheritedWidget {
  final BappActionCallback onAction;
  const BappActionDispatcher({super.key, required this.onAction, required super.child});

  static BappActionDispatcher? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BappActionDispatcher>();

  @override
  bool updateShouldNotify(BappActionDispatcher oldWidget) => false;
}
