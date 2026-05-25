import 'package:flutter/widgets.dart';

/// Holds editable form values for input nodes within a form/settings screen.
class FormScope extends InheritedWidget {
  final Map<String, dynamic> values;
  final void Function(String name, dynamic value) setValue;

  const FormScope({
    super.key,
    required this.values,
    required this.setValue,
    required super.child,
  });

  static FormScope? of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<FormScope>();

  @override
  bool updateShouldNotify(FormScope oldWidget) => true;
}
