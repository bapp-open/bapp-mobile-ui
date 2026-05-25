import 'package:flutter/widgets.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';

/// Provides an action callback to descendant button nodes. The app supplies the
/// callback (which uses ActionRunner + applies the result).
typedef BappActionCallback = Future<void> Function(
    Node button, Map<String, dynamic>? record);

class BappActionDispatcher extends InheritedWidget {
  final BappActionCallback onAction;
  const BappActionDispatcher({super.key, required this.onAction, required super.child});

  static BappActionDispatcher? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BappActionDispatcher>();

  @override
  bool updateShouldNotify(BappActionDispatcher oldWidget) => false;
}
