import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/templates/template_registry.dart';

/// Configuration for a BappMobileApp. Only [host] + [project] are required;
/// everything else (navigation, screens, theme) comes from the backend.
class BappMobileConfig {
  final String host;
  final String project; // mobile app slug (also the bapp_auth app)
  final String? clientId; // Keycloak client id; defaults to project
  final Map<String, NodeBuilder>? nodes; // custom node-kinds
  final Map<String, TemplateBuilder>? templates; // custom templates
  const BappMobileConfig({
    required this.host,
    required this.project,
    this.clientId,
    this.nodes,
    this.templates,
  });
}
