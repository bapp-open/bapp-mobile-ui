import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/form_scope.dart';

void registerInputNodes(NodeRegistry registry) {
  registry.register('text_input', (c, n) => _textField(c, n));
  registry.register('number_input', (c, n) => _textField(c, n, number: true));
  registry.register('textarea', (c, n) => _textField(c, n, lines: 4));

  registry.register('switch', (c, n) {
    final name = n.props['name'] as String? ?? '';
    final label = n.props['label'] as String? ?? name;
    final scope = FormScope.of(c);
    final value = (scope?.values[name] as bool?) ?? false;
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: (v) => scope?.setValue(name, v),
    );
  });

  registry.register('select', (c, n) {
    final name = n.props['name'] as String? ?? '';
    final label = n.props['label'] as String? ?? name;
    final options = (n.props['options'] as List?)?.cast<dynamic>() ?? const [];
    final scope = FormScope.of(c);
    final value = scope?.values[name];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InputDecorator(
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<dynamic>(
            isExpanded: true,
            value: value,
            items: [
              for (final o in options)
                DropdownMenuItem(
                  value: o is Map ? o['value'] : o,
                  child: Text('${o is Map ? (o['label'] ?? o['value']) : o}'),
                ),
            ],
            onChanged: (v) => scope?.setValue(name, v),
          ),
        ),
      ),
    );
  });

  // v1: date_picker rendered as plain text field
  registry.register('date_picker', (c, n) => _textField(c, n));
}

Widget _textField(BuildContext c, Node n, {bool number = false, int lines = 1}) {
  final name = n.props['name'] as String? ?? '';
  final label = n.props['label'] as String? ?? name;
  final scope = FormScope.of(c);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      initialValue: scope?.values[name]?.toString() ?? '',
      keyboardType: number ? TextInputType.number : TextInputType.text,
      maxLines: lines,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onChanged: (v) =>
          scope?.setValue(name, number ? num.tryParse(v) ?? v : v),
    ),
  );
}
