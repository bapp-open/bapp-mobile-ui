import 'package:flutter/widgets.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/templates/template_registry.dart';

/// Configuration for a BappMobileApp. [host] is required; [project] pins the
/// app to a specific mobile slug (when null the app-first picker is shown).
class BappMobileConfig {
  final String host;
  final String? project; // mobile app slug — pins to one app when set
  final String? clientId; // Keycloak client id; defaults to project
  final Map<String, NodeBuilder>? nodes; // custom node-kinds
  final Map<String, TemplateBuilder>? templates; // custom templates
  /// Optional locale override — forces the SDK's chrome strings to this
  /// language instead of following the device locale.
  final Locale? locale;
  const BappMobileConfig({
    required this.host,
    this.project,
    this.clientId,
    this.nodes,
    this.templates,
    this.locale,
  });
}
