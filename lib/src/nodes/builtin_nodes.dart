import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/nodes/field_widget.dart';
import 'package:bapp_mobile_ui/src/nodes/input_nodes.dart';
import 'package:bapp_mobile_ui/src/actions/action_dispatcher.dart';
import 'package:bapp_mobile_ui/src/render/record_scope.dart';
import 'package:bapp_mobile_ui/src/render/navigation_dispatcher.dart';

/// Registers the v1 built-in node kinds into [registry]. `list` is intentionally
/// NOT registered here — it is handled by the list template.
void registerBuiltinNodes(NodeRegistry registry) {
  registry.register('column', (c, n) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: registry.buildChildren(c, n),
      ));
  registry.register('row', (c, n) => Row(
        children: registry
            .buildChildren(c, n)
            .map((w) => Flexible(child: w))
            .toList(),
      ));
  registry.register('card', (c, n) {
    final inner = Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: registry.buildChildren(c, n),
        ),
      ),
    );
    if (n.onTap == null) return inner;
    return InkWell(
      onTap: () {
        final nav = BappNavigationDispatcher.of(c);
        if (nav != null) nav.onNavigate(n.onTap!, RecordScope.of(c));
      },
      child: inner,
    );
  });
  registry.register('section', (c, n) {
    final title = n.props['title'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null && title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ...registry.buildChildren(c, n),
      ],
    );
  });
  registry.register('text', (c, n) => Text('${n.props['value'] ?? ''}'));
  registry.register('field', buildFieldWidget);
  registry.register('button', (c, n) => _button(c, n));
  registry.register('tile', (c, n) {
    final label = n.props['label'] as String? ?? '';
    final inner = Card(
      child: ListTile(
        leading: const Icon(Icons.dashboard_outlined),
        title: Text(label),
        trailing: n.onTap != null ? const Icon(Icons.chevron_right) : null,
      ),
    );
    if (n.onTap == null) return inner;
    return InkWell(
      onTap: () => BappNavigationDispatcher.of(c)?.onNavigate(
          n.onTap!, RecordScope.of(c)),
      child: inner,
    );
  });
  registerInputNodes(registry);
}

Widget _button(BuildContext context, Node node) {
  final label = node.props['label'] as String? ?? '';
  final style = node.props['style'] as String? ?? 'primary';
  void onPressed() {
    final dispatcher = BappActionDispatcher.of(context);
    if (dispatcher != null) {
      dispatcher.onAction(node, RecordScope.of(context));
    }
  }
  switch (style) {
    case 'text':
      return TextButton(onPressed: onPressed, child: Text(label));
    case 'secondary':
      return OutlinedButton(onPressed: onPressed, child: Text(label));
    default:
      return FilledButton(onPressed: onPressed, child: Text(label));
  }
}
