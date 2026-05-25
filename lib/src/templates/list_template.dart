import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/record_scope.dart';

/// Renders a `list` screen: resolves the screen's data binding to records via
/// [MobileApi.listRecords], then renders the screen's first child node (the row
/// card) once per record inside a RecordScope.
class ListTemplate extends StatefulWidget {
  final ScreenDef screen;
  final MobileApi api;
  final NodeRegistry nodes;
  const ListTemplate({
    super.key,
    required this.screen,
    required this.api,
    required this.nodes,
  });

  @override
  State<ListTemplate> createState() => _ListTemplateState();
}

class _ListTemplateState extends State<ListTemplate> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<Map<String, dynamic>>> _fetch() {
    final data = widget.screen.data;
    if (data == null) return Future.value(const []);
    return widget.api.listRecords(data.contentType, data.params);
  }

  @override
  Widget build(BuildContext context) {
    final itemNode = widget.screen.node.children.isNotEmpty
        ? widget.screen.node.children.first
        : null;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final records = snap.data ?? const [];
        if (records.isEmpty) {
          return const Center(child: Text('No items'));
        }
        if (itemNode == null) return const SizedBox.shrink();
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, i) => RecordScope(
            record: records[i],
            child: Builder(
              builder: (innerCtx) => widget.nodes.build(innerCtx, itemNode),
            ),
          ),
        );
      },
    );
  }
}
