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
    case 'date':
    case 'text':
    default:
      return Text(text);
  }
}
