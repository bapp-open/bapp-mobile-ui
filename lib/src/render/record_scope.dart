import 'package:flutter/widgets.dart';

/// Carries the current data record down the widget tree so `field` nodes can
/// resolve their values. List rows wrap each item's subtree in a RecordScope.
class RecordScope extends InheritedWidget {
  final Map<String, dynamic>? record;
  const RecordScope({super.key, required this.record, required super.child});

  static Map<String, dynamic>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RecordScope>()?.record;

  @override
  bool updateShouldNotify(RecordScope oldWidget) => oldWidget.record != record;
}

/// Resolve a field reference against a record. Supports a bare field name
/// (`"name"`) or the `"$field(name)"` interpolation form used in the contract.
dynamic resolveFieldValue(String expr, Map<String, dynamic>? record) {
  if (record == null) return null;
  final match = RegExp(r'^\$field\((.+)\)$').firstMatch(expr.trim());
  final name = match != null ? match.group(1)!.trim() : expr.trim();
  return record[name];
}
