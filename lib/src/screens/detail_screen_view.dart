import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/actions/action_dispatcher.dart';
import 'package:bapp_mobile_ui/src/actions/action_runner.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/record_scope.dart';
import 'package:bapp_mobile_ui/src/render/screen_renderer.dart';

class DetailScreenView extends StatefulWidget {
  final MobileApi api;
  final NodeRegistry nodes;
  final String project;
  final String screenKey; // e.g. company_passwords.passwordentry:detail
  final String recordId;
  const DetailScreenView({
    super.key,
    required this.api,
    required this.nodes,
    required this.project,
    required this.screenKey,
    required this.recordId,
  });

  @override
  State<DetailScreenView> createState() => _DetailScreenViewState();
}

class _DetailScreenViewState extends State<DetailScreenView> {
  late Future<({ScreenDef screen, Map<String, dynamic>? record})> _future;

  String get _contentType => widget.screenKey.split(':').first;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({ScreenDef screen, Map<String, dynamic>? record})> _load() async {
    final screenJson =
        await widget.api.detailIntrospect(_contentType, widget.project);
    final screen = ScreenDef.fromJson(screenJson);
    final record = await widget.api.getRecord(_contentType, widget.recordId);
    return (screen: screen, record: record);
  }

  Future<void> _runAction(String code) async {
    final result =
        await ActionRunner(widget.api).run(code, {'pk': widget.recordId});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(result.message ?? (result.success ? 'Done' : 'Failed'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({ScreenDef screen, Map<String, dynamic>? record})>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
              body: Center(child: Text('Error: ${snap.error}')));
        }
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final screen = snap.data!.screen;
        final record = snap.data!.record;
        return Scaffold(
          appBar: AppBar(
            title: Text(screen.title ?? 'Detail'),
            actions: [
              for (final a in screen.actions)
                TextButton(
                  onPressed: () => _runAction(a['key'] as String),
                  child: Text(
                    '${a['label'] ?? a['key']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: BappActionDispatcher(
              onAction: (Node n, Map<String, dynamic>? rec) =>
                  _runAction(n.props['task'] as String? ?? ''),
              child: RecordScope(
                record: record,
                child: Builder(
                  builder: (c) =>
                      ScreenRenderer(registry: widget.nodes, node: screen.node),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
