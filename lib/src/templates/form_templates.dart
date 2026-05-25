import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/actions/action_runner.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/screen_renderer.dart';
import 'package:bapp_mobile_ui/src/render/form_scope.dart';
import 'package:bapp_mobile_ui/src/render/project_scope.dart';

/// Stateful widget that handles both `form` and `settings` templates.
///
/// - **form**: renders [screen.node] inside a [FormScope] with an empty initial
///   state; Save submits the form values via the screen's submit action.
/// - **settings** (`settings: true`): on init fetches current values from
///   `mobile.getsettings` and prefills the form; Save calls `mobile.setsettings`
///   with `{app: project, ...values}`.
class FormTemplate extends StatefulWidget {
  final ScreenDef screen;
  final MobileApi api;
  final NodeRegistry nodes;
  final bool settings;

  const FormTemplate({
    super.key,
    required this.screen,
    required this.api,
    required this.nodes,
    this.settings = false,
  });

  @override
  State<FormTemplate> createState() => _FormTemplateState();
}

class _FormTemplateState extends State<FormTemplate> {
  Map<String, dynamic> _values = {};
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.settings) {
      // Defer until first frame so ProjectScope is available in context.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadSettings();
      });
    }
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    try {
      final project = ProjectScope.of(context) ?? '';
      final res = await widget.api.runAction(
        'mobile.getsettings',
        {'app': project},
      );
      final fetched = (res?['values'] as Map?)?.cast<String, dynamic>() ?? {};
      if (mounted) setState(() => _values = fetched);
    } catch (_) {
      // Non-fatal: form starts empty
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final submitAction = widget.screen.actions.cast<Map<String, dynamic>?>()
        .firstWhere((a) => a?['submit'] == true, orElse: () => null);
    if (submitAction == null) return;

    final code = submitAction['key'] as String? ?? '';
    if (code.isEmpty) return;

    final project = ProjectScope.of(context) ?? '';
    final payload = widget.settings
        ? <String, dynamic>{'app': project, ..._values}
        : Map<String, dynamic>.from(_values);

    setState(() => _saving = true);
    try {
      final result = await ActionRunner(widget.api).run(code, payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ??
              (result.success ? 'Saved' : 'Failed')),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return FormScope(
      values: _values,
      setValue: (k, v) => setState(() => _values[k] = v),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ScreenRenderer(registry: widget.nodes, node: widget.screen.node),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
