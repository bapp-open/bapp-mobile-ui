import 'package:flutter/material.dart';
import 'package:bapp_auth/bapp_auth.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/actions/action_dispatcher.dart';
import 'package:bapp_mobile_ui/src/actions/action_runner.dart';
import 'package:bapp_mobile_ui/src/bootstrap/bootstrap_service.dart';
import 'package:bapp_mobile_ui/src/config/bapp_mobile_config.dart';
import 'package:bapp_mobile_ui/src/models/manifest.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';
import 'package:bapp_mobile_ui/src/nodes/builtin_nodes.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/cache/cache_store.dart';
import 'package:bapp_mobile_ui/src/screens/screen_service.dart';
import 'package:bapp_mobile_ui/src/templates/template_registry.dart';

class BappMobileApp extends StatefulWidget {
  final BappMobileConfig config;
  final MobileApi? apiOverride; // tests / embedding: skip real auth
  const BappMobileApp({super.key, required this.config, this.apiOverride});

  @override
  State<BappMobileApp> createState() => _BappMobileAppState();
}

class _BappMobileAppState extends State<BappMobileApp> {
  late final NodeRegistry _nodes;
  late final TemplateRegistry _templates;
  MobileApi? _api;
  Future<BootstrapManifest>? _bootstrap;
  String? _error;
  int _navIndex = 0;
  int _refreshTick = 0;
  CacheStore? _cache;

  @override
  void initState() {
    super.initState();
    _nodes = NodeRegistry();
    registerBuiltinNodes(_nodes);
    if (widget.config.nodes != null) _nodes.registerAll(widget.config.nodes!);
    _templates = TemplateRegistry();
    registerBuiltinTemplates(_templates);
    if (widget.config.templates != null) {
      _templates.registerAll(widget.config.templates!);
    }
    _init();
  }

  Future<void> _init() async {
    try {
      final api = widget.apiOverride ?? await _authenticate();
      if (!mounted) return;
      final cache = await _tryCreateCache();
      setState(() {
        _api = api;
        _cache = cache;
        _bootstrap =
            BootstrapService(api: api, project: widget.config.project).load();
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  /// Best-effort cache. Returns null when the platform plugin is unavailable
  /// (e.g. in widget tests without a SharedPreferences mock) — the app then
  /// runs uncached rather than failing to boot.
  Future<CacheStore?> _tryCreateCache() async {
    try {
      return await CacheStore.create(
          namespace: '${widget.config.host}:${widget.config.project}');
    } catch (_) {
      return null;
    }
  }

  Future<MobileApi> _authenticate() async {
    // Real Keycloak path (not exercised in widget tests).
    final auth = BappAuth(
      config: BappAuthConfig(
        host: widget.config.host,
        app: widget.config.project,
        clientId: widget.config.clientId ?? widget.config.project,
        ssoAutoLogin: true,
      ),
    );
    await auth.initialize();
    if (!auth.isAuthenticated) {
      await auth.loginWithSSO();
    }
    auth.setApp(widget.config.project);
    return BappMobileApi(auth.apiClient);
  }

  Color _primary(BootstrapManifest m) {
    final hex = m.app.theme?.primary.replaceAll('#', '');
    if (hex == null || hex.length != 6) return const Color(0xFF1E2A3C);
    final value = int.tryParse('FF$hex', radix: 16);
    return value == null ? const Color(0xFF1E2A3C) : Color(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _error != null
          ? Scaffold(body: Center(child: Text('Error: $_error')))
          : _api == null || _bootstrap == null
              ? const Scaffold(
                  body: Center(child: CircularProgressIndicator()))
              : FutureBuilder<BootstrapManifest>(
                  future: _bootstrap,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Scaffold(
                          body: Center(
                              child: Text('Error: ${snap.error}')));
                    }
                    if (!snap.hasData) {
                      return const Scaffold(
                          body:
                              Center(child: CircularProgressIndicator()));
                    }
                    return _shell(context, snap.data!);
                  },
                ),
    );
  }

  Widget _shell(BuildContext context, BootstrapManifest m) {
    final nav = m.navigation;
    if (nav.isEmpty) {
      return const Scaffold(body: Center(child: Text('No screens')));
    }
    final index = _navIndex.clamp(0, nav.length - 1);
    final current = nav[index];
    final theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: _primary(m)),
    );
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: Text(current.label)),
        body: _screen(context, m, current),
        bottomNavigationBar: nav.length > 1
            ? BottomNavigationBar(
                currentIndex: index,
                onTap: (i) => setState(() => _navIndex = i),
                items: [
                  for (final n in nav)
                    BottomNavigationBarItem(
                        icon: const Icon(Icons.dashboard), label: n.label),
                ],
              )
            : null,
      ),
    );
  }

  Widget _screen(BuildContext context, BootstrapManifest m, NavItem item) {
    final ref = m.screens.firstWhere(
      (s) => s.key == item.screen,
      orElse: () =>
          ScreenRef(key: item.screen ?? '', template: 'list', version: '1'),
    );
    return FutureBuilder<ScreenDef>(
      key: ValueKey('${ref.key}:$_refreshTick'),
      future: ScreenService(
        api: _api!,
        project: widget.config.project,
        cache: _cache,
      ).load(ref),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return BappActionDispatcher(
          onAction: _runAction,
          child: Builder(
            builder: (c) => _templates.build(c, snap.data!, _api!, _nodes),
          ),
        );
      },
    );
  }

  Future<void> _runAction(Node button, Map<String, dynamic>? record) async {
    final code = button.props['task'] as String?;
    if (code == null) return;
    final payload = <String, dynamic>{};
    final id = record?['id'];
    if (id != null) payload['pk'] = id;
    final result = await ActionRunner(_api!).run(code, payload);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              result.message ?? (result.success ? 'Done' : 'Failed'))),
    );
    // Refresh after a successful action. Bumping _refreshTick re-runs the
    // screen FutureBuilder: the screen *definition* is served from the
    // version-keyed cache (no network), while the list template re-fetches its
    // records live. Record data is never cached, so `invalidates` is covered by
    // this live re-fetch; eviction of cached record data lands when an offline
    // data cache is added.
    if (result.success) {
      setState(() => _refreshTick++);
    }
  }
}
