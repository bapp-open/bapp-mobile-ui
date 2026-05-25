class ThemeInfo {
  final String primary;
  final String mode;
  const ThemeInfo({required this.primary, required this.mode});
  factory ThemeInfo.fromJson(Map<String, dynamic> j) => ThemeInfo(
        primary: (j['primary'] as String?) ?? '#000000',
        mode: (j['mode'] as String?) ?? 'light',
      );
}

class MobileAppInfo {
  final String slug;
  final String name;
  final String? icon;
  final String? webApp;
  final ThemeInfo? theme;
  const MobileAppInfo({
    required this.slug,
    required this.name,
    this.icon,
    this.webApp,
    this.theme,
  });
  factory MobileAppInfo.fromJson(Map<String, dynamic> j) => MobileAppInfo(
        slug: j['slug'] as String,
        name: (j['name'] as String?) ?? (j['slug'] as String),
        icon: j['icon'] as String?,
        webApp: j['web_app'] as String?,
        theme: j['theme'] == null
            ? null
            : ThemeInfo.fromJson((j['theme'] as Map).cast<String, dynamic>()),
      );
}

class NavItem {
  final String key;
  final String label;
  final String? icon;
  final String? screen;
  final List<NavItem> children;
  const NavItem({
    required this.key,
    required this.label,
    this.icon,
    this.screen,
    this.children = const [],
  });
  factory NavItem.fromJson(Map<String, dynamic> j) => NavItem(
        key: j['key'] as String,
        label: (j['label'] as String?) ?? '',
        icon: j['icon'] as String?,
        screen: j['screen'] as String?,
        children: ((j['children'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(NavItem.fromJson)
            .toList(),
      );
}

class ScreenRef {
  final String key;
  final String template;
  final String version;
  const ScreenRef({required this.key, required this.template, required this.version});
  factory ScreenRef.fromJson(Map<String, dynamic> j) => ScreenRef(
        key: j['key'] as String,
        template: (j['template'] as String?) ?? 'custom',
        version: (j['version'] ?? '1').toString(),
      );
}

class BootstrapManifest {
  final String version;
  final MobileAppInfo app;
  final List<NavItem> navigation;
  final List<ScreenRef> screens;
  final Map<String, dynamic> capabilities;
  const BootstrapManifest({
    required this.version,
    required this.app,
    this.navigation = const [],
    this.screens = const [],
    this.capabilities = const {},
  });
  factory BootstrapManifest.fromJson(Map<String, dynamic> j) => BootstrapManifest(
        version: (j['version'] ?? '1').toString(),
        app: MobileAppInfo.fromJson((j['app'] as Map).cast<String, dynamic>()),
        navigation: ((j['navigation'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(NavItem.fromJson)
            .toList(),
        screens: ((j['screens'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(ScreenRef.fromJson)
            .toList(),
        capabilities:
            (j['capabilities'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
}
