import 'package:flutter/material.dart';

/// Resolves a backend icon-name string (e.g. `'fa-key'`) to a widget. Return
/// `null` to let the SDK fall back to its built-in Material mapping.
///
/// This package deliberately ships **no icon fonts**. Backends only ever send
/// icon *names* (plain strings — not copyrighted assets). A host app that owns
/// an icon-set license (e.g. Font Awesome Pro) declares those fonts in its own
/// `pubspec.yaml` and supplies a resolver via `BappMobileConfig.iconResolver`,
/// so the licensed glyphs live only in that app's binary — never redistributed
/// inside this package.
typedef IconResolver = Widget? Function(String name, {double size, Color? color});

/// Built-in fallback mapping a handful of common names to free Material icons.
/// Used whenever no [IconResolver] is supplied or the resolver returns null.
IconData defaultIconData(String? name) {
  switch (name) {
    case 'fa-circle-info':
    case 'info':
      return Icons.info_outline;
    case 'fa-key':
    case 'key':
      return Icons.key;
    case 'fa-gear':
    case 'settings':
      return Icons.settings;
    case 'fa-house':
    case 'home':
      return Icons.home;
    case 'fa-shield-keyhole':
    case 'shield':
      return Icons.shield_outlined;
    case 'fa-list':
      return Icons.list;
    case 'fa-plus':
      return Icons.add;
    case 'fa-truck-ramp-box':
    case 'truck':
      return Icons.local_shipping_outlined;
    default:
      return Icons.circle;
  }
}

/// Renders an icon by name, preferring [resolver] (e.g. the host app's licensed
/// Font Awesome glyphs) and falling back to the built-in Material mapping.
Widget bappIcon(String? name,
    {IconResolver? resolver, double size = 20, Color? color}) {
  if (name != null && name.isNotEmpty && resolver != null) {
    final widget = resolver(name, size: size, color: color);
    if (widget != null) return widget;
  }
  return Icon(defaultIconData(name), size: size, color: color);
}

/// Builds an [IconResolver] for an icon font the host app **embeds** in its own
/// `pubspec.yaml` (so the glyphs ship inside the app binary — nothing is loaded
/// at runtime and nothing licensed lives in this package).
///
/// [fontFamily] is the family declared in pubspec; [glyphs] maps icon names to
/// unicode codepoints (copy them from your kit's `metadata/icons.json`). Keys
/// may be stored with or without a style prefix — lookups try the raw name and
/// each of [stripPrefixes] removed. Unknown names return null so the SDK falls
/// back to its Material mapping. [fontPackage] is for fonts shipped via another
/// Flutter package.
///
/// Because glyphs are chosen at runtime, build with `--no-tree-shake-icons`.
///
/// ```dart
/// BappMobileConfig(
///   iconResolver: fontIconResolver(
///     fontFamily: 'Font Awesome 6 Pro',
///     glyphs: {'key': 0xf084, 'gear': 0xf013},
///   ),
/// );
/// ```
IconResolver fontIconResolver({
  required String fontFamily,
  required Map<String, int> glyphs,
  String? fontPackage,
  List<String> stripPrefixes = const ['fa-'],
}) {
  int? lookup(String name) {
    final direct = glyphs[name];
    if (direct != null) return direct;
    for (final prefix in stripPrefixes) {
      if (name.startsWith(prefix)) {
        final stripped = glyphs[name.substring(prefix.length)];
        if (stripped != null) return stripped;
      }
    }
    return null;
  }

  return (String name, {double size = 20, Color? color}) {
    final codepoint = lookup(name);
    if (codepoint == null) return null;
    return Icon(IconData(codepoint, fontFamily: fontFamily, fontPackage: fontPackage),
        size: size, color: color);
  };
}

/// Combines resolvers, returning the first non-null result. Useful when an icon
/// set spans multiple embedded font families (e.g. Font Awesome Solid + Brands).
IconResolver combineIconResolvers(List<IconResolver> resolvers) {
  return (String name, {double size = 20, Color? color}) {
    for (final resolver in resolvers) {
      final widget = resolver(name, size: size, color: color);
      if (widget != null) return widget;
    }
    return null;
  };
}
