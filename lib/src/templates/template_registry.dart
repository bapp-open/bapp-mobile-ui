import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/screen_renderer.dart';
import 'package:bapp_mobile_ui/src/templates/list_template.dart';
import 'package:bapp_mobile_ui/src/templates/form_templates.dart';

/// Builds a full screen for a given template name. Deps (api, nodes) are passed
/// explicitly so templates are testable in isolation.
typedef TemplateBuilder = Widget Function(
    BuildContext context, ScreenDef screen, MobileApi api, NodeRegistry nodes);

class TemplateRegistry {
  final Map<String, TemplateBuilder> _builders = {};
  void register(String name, TemplateBuilder b) => _builders[name] = b;
  void registerAll(Map<String, TemplateBuilder> m) => _builders.addAll(m);
  bool has(String name) => _builders.containsKey(name);

  Widget build(BuildContext context, ScreenDef screen, MobileApi api, NodeRegistry nodes) {
    final b = _builders[screen.template];
    if (b == null) return UnsupportedTemplate(name: screen.template);
    return b(context, screen, api, nodes);
  }
}

void registerBuiltinTemplates(TemplateRegistry registry) {
  registry.register('list',
      (c, s, api, nodes) => ListTemplate(screen: s, api: api, nodes: nodes));
  registry.register('dashboard',
      (c, s, api, nodes) => SingleChildScrollView(
            child: ScreenRenderer(registry: nodes, node: s.node),
          ));
  registry.register('form',
      (c, s, api, nodes) =>
          FormTemplate(screen: s, api: api, nodes: nodes));
  registry.register('settings',
      (c, s, api, nodes) =>
          FormTemplate(screen: s, api: api, nodes: nodes, settings: true));
}

class UnsupportedTemplate extends StatelessWidget {
  final String name;
  const UnsupportedTemplate({super.key, required this.name});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('unsupported template: $name'));
}
