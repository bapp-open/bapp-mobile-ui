import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';

/// Builds a widget for a single node. Builders read the current record via
/// `RecordScope.of(context)` and recurse via the registry for children.
typedef NodeBuilder = Widget Function(BuildContext context, Node node);

class NodeRegistry {
  final Map<String, NodeBuilder> _builders = {};

  void register(String kind, NodeBuilder builder) => _builders[kind] = builder;
  void registerAll(Map<String, NodeBuilder> builders) =>
      _builders.addAll(builders);
  bool has(String kind) => _builders.containsKey(kind);

  Widget build(BuildContext context, Node node) {
    final builder = _builders[node.kind];
    if (builder == null) return UnsupportedNode(kind: node.kind);
    return builder(context, node);
  }

  /// Convenience to build a node's children in order.
  List<Widget> buildChildren(BuildContext context, Node node) =>
      node.children.map((c) => build(context, c)).toList();
}

/// Visible, non-crashing placeholder for node kinds the client doesn't know.
class UnsupportedNode extends StatelessWidget {
  final String kind;
  const UnsupportedNode({super.key, required this.kind});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text('unsupported: $kind',
            style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
      );
}
