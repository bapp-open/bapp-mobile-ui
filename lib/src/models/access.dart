/// Models for the mobile.access task response.
library;

class AccessUser {
  final String sub, email, name;
  const AccessUser({required this.sub, required this.email, required this.name});
  factory AccessUser.fromJson(Map<String, dynamic> j) => AccessUser(
      sub: (j['sub'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
      name: (j['name'] ?? '').toString());
}

class AccessTenant {
  final String id, name;
  const AccessTenant({required this.id, required this.name});
  factory AccessTenant.fromJson(Map<String, dynamic> j) =>
      AccessTenant(id: j['id'].toString(), name: (j['name'] ?? j['id']).toString());
}

class AccessApp {
  final String slug, name, webApp;
  final String? icon;
  const AccessApp(
      {required this.slug, required this.name, required this.webApp, this.icon});
  factory AccessApp.fromJson(Map<String, dynamic> j) => AccessApp(
      slug: j['slug'].toString(),
      name: (j['name'] ?? j['slug']).toString(),
      webApp: (j['web_app'] ?? '').toString(),
      icon: j['icon'] as String?);
}

class Membership {
  final AccessTenant tenant;
  final List<AccessApp> apps;
  const Membership({required this.tenant, required this.apps});
  factory Membership.fromJson(Map<String, dynamic> j) => Membership(
      tenant: AccessTenant.fromJson((j['tenant'] as Map).cast<String, dynamic>()),
      apps: ((j['apps'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(AccessApp.fromJson)
          .toList());
}

class AccessInfo {
  final AccessUser user;
  final List<Membership> memberships;
  const AccessInfo({required this.user, required this.memberships});
  factory AccessInfo.fromJson(Map<String, dynamic> j) => AccessInfo(
      user: AccessUser.fromJson(
          (j['user'] as Map?)?.cast<String, dynamic>() ?? const {}),
      memberships: ((j['memberships'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Membership.fromJson)
          .toList());

  /// Flat (app, tenant) pairs.
  List<({AccessApp app, AccessTenant tenant})> get pairs => [
        for (final m in memberships)
          for (final a in m.apps) (app: a, tenant: m.tenant),
      ];

  /// Distinct apps (by slug) for the app-first picker, each with the tenants
  /// offering it.
  List<({AccessApp app, List<AccessTenant> tenants})> appsFirst() {
    final bySlug = <String, ({AccessApp app, List<AccessTenant> tenants})>{};
    for (final p in pairs) {
      final e =
          bySlug.putIfAbsent(p.app.slug, () => (app: p.app, tenants: <AccessTenant>[]));
      if (!e.tenants.any((t) => t.id == p.tenant.id)) e.tenants.add(p.tenant);
    }
    return bySlug.values.toList();
  }
}
