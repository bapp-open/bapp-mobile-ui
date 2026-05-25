import 'package:bapp_mobile_ui/src/models/node.dart';

class DataBinding {
  final String source;
  final String contentType;
  final String method;
  final Map<String, dynamic> params;

  const DataBinding({
    required this.source,
    required this.contentType,
    required this.method,
    this.params = const {},
  });

  factory DataBinding.fromJson(Map<String, dynamic> j) => DataBinding(
        source: (j['source'] as String?) ?? 'content_type',
        contentType: (j['content_type'] as String?) ?? '',
        method: (j['method'] as String?) ?? 'list',
        params: (j['params'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
}

class ScreenDef {
  final String key;
  final String template;
  final String? title;
  final String version;
  final DataBinding? data;
  final Node node;
  final List<Map<String, dynamic>> actions;

  const ScreenDef({
    required this.key,
    required this.template,
    required this.version,
    required this.node,
    this.title,
    this.data,
    this.actions = const [],
  });

  factory ScreenDef.fromJson(Map<String, dynamic> j) => ScreenDef(
        key: j['key'] as String,
        template: j['template'] as String,
        title: j['title'] as String?,
        version: (j['version'] ?? '1').toString(),
        data: j['data'] == null
            ? null
            : DataBinding.fromJson((j['data'] as Map).cast<String, dynamic>()),
        node: Node.fromJson((j['node'] as Map).cast<String, dynamic>()),
        actions: ((j['actions'] as List?) ?? const [])
            .cast<Map<String, dynamic>>(),
      );
}
