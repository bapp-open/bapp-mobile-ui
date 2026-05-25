import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last (mobileSlug, webApp, tenantId) selection so the app
/// can resume without showing the picker on every launch.
///
/// Keys are namespaced by host so different backends don't collide.
/// All operations are best-effort: if shared_preferences is unavailable
/// (e.g. in widget tests without a mock) the store silently does nothing.
class SelectionStore {
  SelectionStore._(this._prefs, this._ns);

  final SharedPreferences _prefs;
  final String _ns;

  static Future<SelectionStore?> create({required String host}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ns = 'bmu:sel:${host.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
      return SelectionStore._(prefs, ns);
    } catch (_) {
      return null;
    }
  }

  String get _kSlug => '$_ns:mobileSlug';
  String get _kWebApp => '$_ns:webApp';
  String get _kTenant => '$_ns:tenantId';

  Future<({String mobileSlug, String webApp, String tenantId})?> read() async {
    try {
      final slug = _prefs.getString(_kSlug);
      final webApp = _prefs.getString(_kWebApp);
      final tenant = _prefs.getString(_kTenant);
      if (slug == null || webApp == null || tenant == null) return null;
      return (mobileSlug: slug, webApp: webApp, tenantId: tenant);
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required String mobileSlug,
    required String webApp,
    required String tenantId,
  }) async {
    try {
      await _prefs.setString(_kSlug, mobileSlug);
      await _prefs.setString(_kWebApp, webApp);
      await _prefs.setString(_kTenant, tenantId);
    } catch (_) {}
  }

  Future<void> clear() async {
    try {
      await _prefs.remove(_kSlug);
      await _prefs.remove(_kWebApp);
      await _prefs.remove(_kTenant);
    } catch (_) {}
  }
}
