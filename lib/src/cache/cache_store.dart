import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Version-keyed JSON cache over shared_preferences.
///
/// Entries are stored under `bmu:<namespace>:<key>` as a small envelope
/// `{"v": <version>, "d": <json>}`. [getJson] returns the data only when the
/// stored version matches the requested one, so a backend version bump
/// transparently invalidates stale entries.
class CacheStore {
  CacheStore._(this._prefs, this._namespace);

  final SharedPreferences _prefs;
  final String _namespace;

  static Future<CacheStore> create({required String namespace}) async {
    final prefs = await SharedPreferences.getInstance();
    return CacheStore._(prefs, namespace);
  }

  String _k(String key) => 'bmu:$_namespace:$key';

  Future<void> putJson(String key, String version, Map<String, dynamic> data) async {
    await _prefs.setString(_k(key), jsonEncode({'v': version, 'd': data}));
  }

  Future<Map<String, dynamic>?> getJson(String key, String version) async {
    final raw = _prefs.getString(_k(key));
    if (raw == null) return null;
    final env = jsonDecode(raw) as Map<String, dynamic>;
    if (env['v'] != version) return null;
    return (env['d'] as Map).cast<String, dynamic>();
  }

  Future<void> invalidate(String key) async {
    await _prefs.remove(_k(key));
  }
}
