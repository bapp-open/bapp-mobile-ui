import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/models/manifest.dart';

class BootstrapService {
  final MobileApi api;
  final String project;
  const BootstrapService({required this.api, required this.project});
  Future<BootstrapManifest> load() async =>
      BootstrapManifest.fromJson(await api.bootstrap(project));
}
