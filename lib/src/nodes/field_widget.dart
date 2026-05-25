import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/render/record_scope.dart';

/// Renders a `field` node by resolving its value from the current RecordScope
/// and styling it per props['widget'] (v1 subset).
Widget buildFieldWidget(BuildContext context, Node node) {
  final name = node.props['name'] as String? ?? '';
  final widget = node.props['widget'] as String? ?? 'text';
  final value = resolveFieldValue(name, RecordScope.of(context));
  final text = value?.toString() ?? '';
  switch (widget) {
    case 'title':
      return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
    case 'subtitle':
      return Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600]));
    case 'money':
      return Text(text, style: const TextStyle(fontWeight: FontWeight.w600));
    case 'chip':
      return Chip(label: Text(text));
    case 'bool':
      return Icon(value == true ? Icons.check : Icons.close, size: 18);
    case 'tag':
      final options =
          (node.props['options'] as Map?)?.cast<String, dynamic>() ?? const {};
      final fallback =
          (node.props['fallback'] as Map?)?.cast<String, dynamic>();
      final variant =
          (options[text] as Map?)?.cast<String, dynamic>() ?? fallback;
      if (variant == null && text.isEmpty) return const SizedBox.shrink();
      final label = (variant?['label'] as String?) ?? text;
      final color = _tagColor(variant?['color'] as String?);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      );
    case 'date':
    case 'text':
    default:
      return Text(text);
  }
}

Color _tagColor(String? name) {
  if (name == null) return Colors.grey;
  if (name.startsWith('#') && name.length == 7) {
    final v = int.tryParse('FF${name.substring(1)}', radix: 16);
    if (v != null) return Color(v);
  }
  switch (name) {
    case 'green':
    case 'success':
      return Colors.green;
    case 'red':
    case 'error':
    case 'danger':
      return Colors.red;
    case 'orange':
    case 'warning':
      return Colors.orange;
    case 'blue':
    case 'info':
    case 'processing':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
