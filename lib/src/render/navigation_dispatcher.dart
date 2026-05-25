import 'package:flutter/widgets.dart';

/// Lets nodes with an `on_tap` navigate request a screen change. The app
/// supplies the callback (resolves params against the record, pushes the route).
typedef BappNavigateCallback = Future<void> Function(
    Map<String, dynamic> onTap, Map<String, dynamic>? record);

class BappNavigationDispatcher extends InheritedWidget {
  final BappNavigateCallback onNavigate;
  const BappNavigationDispatcher(
      {super.key, required this.onNavigate, required super.child});
  static BappNavigationDispatcher? of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<BappNavigationDispatcher>();
  @override
  bool updateShouldNotify(BappNavigationDispatcher oldWidget) => false;
}
