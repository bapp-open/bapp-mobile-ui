import 'package:flutter/widgets.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/icon_resolver.dart';
import 'package:bapp_mobile_ui/src/templates/template_registry.dart';

/// Configuration for a BappMobileApp. [host] is required; [project] pins the
/// app to a specific mobile slug (when null the app-first picker is shown).
class BappMobileConfig {
  final String host;
  final String? project; // mobile app slug — pins to one app when set
  final String? clientId; // Keycloak client id; defaults to project
  final String? customScheme; // OAuth redirect scheme; defaults to com.bapp.auth
  final Map<String, NodeBuilder>? nodes; // custom node-kinds
  final Map<String, TemplateBuilder>? templates; // custom templates

  /// Maps backend icon names (e.g. `'fa-key'`) to widgets, so a host app can
  /// render its own licensed icon set (Font Awesome Pro, a custom font, …).
  /// The SDK ships no icon fonts; return null from the resolver to fall back to
  /// the built-in Material mapping. See `IconResolver`.
  final IconResolver? iconResolver;

  /// Restricts which mobile apps this build may show, by mobile slug. Lets a
  /// single codebase ship multiple branded builds (e.g. a "reception-only"
  /// build) off the same backend. When null, every app the user can reach is
  /// offered. When the filtered set has exactly one app the app picker is
  /// skipped and the flow goes straight to tenant selection.
  final List<String>? allowedApps;

  /// Optional locale override — forces the SDK's chrome strings to this
  /// language instead of following the device locale.
  final Locale? locale;
  const BappMobileConfig({
    required this.host,
    this.project,
    this.clientId,
    this.customScheme,
    this.nodes,
    this.templates,
    this.allowedApps,
    this.iconResolver,
    this.locale,
  });

  /// Whether [slug] is selectable in this build. [project] (a hard pin) and
  /// [allowedApps] (a soft filter) both narrow the set; null/empty = allow all.
  bool allowsApp(String slug) {
    if (project != null) return slug == project;
    final allowed = allowedApps;
    if (allowed == null || allowed.isEmpty) return true;
    return allowed.contains(slug);
  }
}
