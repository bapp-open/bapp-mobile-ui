import 'package:bapp_api_client/bapp_api_client.dart';

/// Narrow surface the renderer depends on. Implemented by [BappMobileApi] in
/// production and by fakes in tests, so the renderer never touches the network.
abstract class MobileApi {
  Future<Map<String, dynamic>> access();
  Future<Map<String, dynamic>> bootstrap(String project);
  Future<Map<String, dynamic>> listIntrospect(String contentType, String project);
  Future<Map<String, dynamic>> detailIntrospect(String contentType, String project);
  Future<Map<String, dynamic>> screenIntrospect(String key, String project);
  Future<List<Map<String, dynamic>>> listRecords(
      String contentType, Map<String, dynamic> params);
  Future<Map<String, dynamic>?> getRecord(String contentType, String id);
  Future<Map<String, dynamic>?> runAction(String code, Map<String, dynamic> payload);
}

/// MobileApi backed by a [BappApiClient]. Mobile UI rides the existing task
/// runner: introspection is `runTask('mobile.bootstrap'|'mobile.listintrospect')`,
/// record data is `list(contentType, ...)`, actions are `runTask(code, payload)`.
class BappMobileApi implements MobileApi {
  BappMobileApi(this._client);
  final BappApiClient _client;

  @override
  Future<Map<String, dynamic>> access() async {
    final res = await _client.runTask('mobile.access', const {});
    return (res as Map).cast<String, dynamic>();
  }

  @override
  Future<Map<String, dynamic>> bootstrap(String project) async {
    final res = await _client.runTask('mobile.bootstrap', {'app': project});
    return (res as Map).cast<String, dynamic>();
  }

  @override
  Future<Map<String, dynamic>> listIntrospect(String contentType, String project) async {
    final res = await _client
        .runTask('mobile.listintrospect', {'ct': contentType, 'app': project});
    return (res as Map).cast<String, dynamic>();
  }

  @override
  Future<Map<String, dynamic>> detailIntrospect(String contentType, String project) async {
    final res = await _client
        .runTask('mobile.detailintrospect', {'ct': contentType, 'app': project});
    return (res as Map).cast<String, dynamic>();
  }

  @override
  Future<Map<String, dynamic>> screenIntrospect(String key, String project) async {
    final res = await _client
        .runTask('mobile.screenintrospect', {'key': key, 'app': project});
    return (res as Map).cast<String, dynamic>();
  }

  @override
  Future<List<Map<String, dynamic>>> listRecords(
      String contentType, Map<String, dynamic> params) async {
    final filters = params.map((k, v) => MapEntry(k, '$v'));
    final paged = await _client.list(contentType, filters);
    return paged.results;
  }

  @override
  Future<Map<String, dynamic>?> getRecord(String contentType, String id) async {
    final res = await _client.get(contentType, id);
    return res is Map ? res.cast<String, dynamic>() : null;
  }

  @override
  Future<Map<String, dynamic>?> runAction(String code, Map<String, dynamic> payload) async {
    final res = await _client.runTask(code, payload);
    return res is Map ? res.cast<String, dynamic>() : null;
  }
}
