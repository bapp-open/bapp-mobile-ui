import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/cache/cache_store.dart';
import 'package:bapp_mobile_ui/src/models/manifest.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';

class ScreenService {
  final MobileApi api;
  final String project;
  final CacheStore? cache;
  const ScreenService({required this.api, required this.project, this.cache});

  Future<ScreenDef> load(ScreenRef ref) async {
    if (cache != null) {
      final cached = await cache!.getJson('screen:${ref.key}', ref.version);
      if (cached != null) return ScreenDef.fromJson(cached);
    }
    final json = await _fetch(ref);
    if (cache != null) await cache!.putJson('screen:${ref.key}', ref.version, json);
    return ScreenDef.fromJson(json);
  }

  Future<Map<String, dynamic>> _fetch(ScreenRef ref) {
    final contentType = ref.key.split(':').first;
    if (ref.template == 'list') return api.listIntrospect(contentType, project);
    if (ref.template == 'detail') return api.detailIntrospect(contentType, project);
    return api.screenIntrospect(ref.key, project);
  }
}
