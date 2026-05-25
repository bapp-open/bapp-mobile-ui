import 'package:flutter/widgets.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';

/// Renders a node tree using the provided registry.
class ScreenRenderer extends StatelessWidget {
  final NodeRegistry registry;
  final Node node;
  const ScreenRenderer({super.key, required this.registry, required this.node});

  @override
  Widget build(BuildContext context) => registry.build(context, node);
}
