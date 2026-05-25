import 'package:flutter/widgets.dart';

/// Provides the active mobile app slug down the widget tree so templates
/// (e.g. settings) can include it in their API calls without needing it
/// threaded through every constructor.
class ProjectScope extends InheritedWidget {
  final String project;
  const ProjectScope({super.key, required this.project, required super.child});

  static String? of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<ProjectScope>()?.project;

  @override
  bool updateShouldNotify(ProjectScope old) => old.project != project;
}
