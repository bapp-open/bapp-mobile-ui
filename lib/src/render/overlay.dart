import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/actions/action_dispatcher.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/record_scope.dart';
import 'package:bapp_mobile_ui/src/render/screen_renderer.dart';
import 'package:bapp_mobile_ui/src/render/navigation_dispatcher.dart';

/// Shows an overlay (bottom sheet or dialog) for an `on_tap` map that carries
/// a `present` key.  The content can be:
///   - an inline `node` map,
///   - an `actions` list (action menu),
///   - a `screen` key referencing another screen/detail.
Future<void> showPresentOverlay(
  BuildContext context,
  Map<String, dynamic> onTap,
  Map<String, dynamic>? record, {
  required MobileApi api,
  required NodeRegistry nodes,
  required String project,
  required Future<void> Function(String code, Map<String, dynamic>? record) onAction,
  required BappNavigateCallback onNavigate,
}) async {
  final mode = onTap['present'] as String? ?? 'sheet';
  final content = _OverlayBody(
    onTap: onTap,
    record: record,
    api: api,
    nodes: nodes,
    project: project,
    onAction: onAction,
    onNavigate: onNavigate,
  );
  if (mode == 'dialog') {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: Padding(padding: const EdgeInsets.all(16), child: content),
      ),
    );
  } else {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }
}

class _OverlayBody extends StatelessWidget {
  final Map<String, dynamic> onTap;
  final Map<String, dynamic>? record;
  final MobileApi api;
  final NodeRegistry nodes;
  final String project;
  final Future<void> Function(String, Map<String, dynamic>?) onAction;
  final BappNavigateCallback onNavigate;

  const _OverlayBody({
    required this.onTap,
    required this.record,
    required this.api,
    required this.nodes,
    required this.project,
    required this.onAction,
    required this.onNavigate,
  });

  Widget _wrap(Widget child) => BappActionDispatcher(
        onAction: (n, rec) =>
            onAction(n.props['task'] as String? ?? '', rec ?? record),
        child: BappNavigationDispatcher(
          onNavigate: onNavigate,
          child: RecordScope(record: record, child: child),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const mainSize = MainAxisSize.min;

    // 1) Inline node
    final nodeJson = onTap['node'];
    if (nodeJson is Map) {
      return _wrap(SingleChildScrollView(
        child: ScreenRenderer(
          registry: nodes,
          node: Node.fromJson(nodeJson.cast<String, dynamic>()),
        ),
      ));
    }

    // 2) Action menu
    final actions = onTap['actions'];
    if (actions is List) {
      return _wrap(Column(
        mainAxisSize: mainSize,
        children: [
          for (final a in actions.cast<Map<String, dynamic>>())
            ListTile(
              title: Text('${a['label'] ?? a['key']}'),
              onTap: () {
                Navigator.of(context).pop();
                onAction(a['key'] as String, record);
              },
            ),
        ],
      ));
    }

    // 3) A screen by key
    final screenKey = onTap['screen'] as String?;
    if (screenKey != null) {
      return _wrap(_ScreenOverlay(
        api: api,
        nodes: nodes,
        project: project,
        screenKey: screenKey,
        params: (onTap['params'] as Map?)?.cast<String, dynamic>(),
        record: record,
      ));
    }

    return const SizedBox.shrink();
  }
}

class _ScreenOverlay extends StatefulWidget {
  final MobileApi api;
  final NodeRegistry nodes;
  final String project;
  final String screenKey;
  final Map<String, dynamic>? params;
  final Map<String, dynamic>? record;

  const _ScreenOverlay({
    required this.api,
    required this.nodes,
    required this.project,
    required this.screenKey,
    this.params,
    this.record,
  });

  @override
  State<_ScreenOverlay> createState() => _ScreenOverlayState();
}

class _ScreenOverlayState extends State<_ScreenOverlay> {
  late Future<({ScreenDef screen, Map<String, dynamic>? record})> _f;

  String get _ct => widget.screenKey.split(':').first;

  @override
  void initState() {
    super.initState();
    _f = _load();
  }

  Future<({ScreenDef screen, Map<String, dynamic>? record})> _load() async {
    final isDetail = widget.screenKey.endsWith(':detail');
    final json = isDetail
        ? await widget.api.detailIntrospect(_ct, widget.project)
        : await widget.api.screenIntrospect(widget.screenKey, widget.project);
    final screen = ScreenDef.fromJson(json);
    Map<String, dynamic>? rec = widget.record;
    // Resolve a pk param against the current record for detail overlays.
    final pk = widget.params?['pk'];
    if (isDetail && pk is String) {
      final m = RegExp(r'^\$field\((.+)\)$').firstMatch(pk.trim());
      final name = m != null ? m.group(1)!.trim() : pk;
      final id =
          widget.record?[name]?.toString() ?? (m == null ? pk : null);
      if (id != null) rec = await widget.api.getRecord(_ct, id);
    }
    return (screen: screen, record: rec);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({ScreenDef screen, Map<String, dynamic>? record})>(
      future: _f,
      builder: (c, snap) {
        if (!snap.hasData) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return RecordScope(
          record: snap.data!.record,
          child: SingleChildScrollView(
            child: ScreenRenderer(
              registry: widget.nodes,
              node: snap.data!.screen.node,
            ),
          ),
        );
      },
    );
  }
}
