import 'package:flutter/material.dart';
import 'package:bapp_auth/bapp_auth.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:bapp_mobile_ui/src/actions/action_dispatcher.dart';
import 'package:bapp_mobile_ui/src/actions/action_runner.dart';
import 'package:bapp_mobile_ui/src/app/selection_screens.dart';
import 'package:bapp_mobile_ui/src/bootstrap/bootstrap_service.dart';
import 'package:bapp_mobile_ui/src/config/bapp_mobile_config.dart';
import 'package:bapp_mobile_ui/src/l10n/app_localizations.dart';
import 'package:bapp_mobile_ui/src/models/access.dart';
import 'package:bapp_mobile_ui/src/models/manifest.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';
import 'package:bapp_mobile_ui/src/nodes/builtin_nodes.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/icon_resolver.dart';
import 'package:bapp_mobile_ui/src/cache/cache_store.dart';
import 'package:bapp_mobile_ui/src/screens/screen_service.dart';
import 'package:bapp_mobile_ui/src/screens/selection_store.dart';
import 'package:bapp_mobile_ui/src/templates/template_registry.dart';
import 'package:bapp_mobile_ui/src/screens/detail_screen_view.dart';
import 'package:bapp_mobile_ui/src/render/navigation_dispatcher.dart';
import 'package:bapp_mobile_ui/src/render/overlay.dart';
import 'package:bapp_mobile_ui/src/render/project_scope.dart';

/// Returns true when [error] represents an HTTP 403 Forbidden response.
/// BappApiClient throws `Exception('BappApiClient: METHOD path failed with 403')`.
bool _isForbidden(Object error) => error.toString().contains(' 403');

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
  final _navigatorKey = GlobalKey<NavigatorState>();

  MobileApi? _api;
  BappAuth? _auth; // non-null only on the real auth path
  Future<BootstrapManifest>? _bootstrap;
  String? _error;
  int? _navIndex; // null → boot into the manifest's home screen
  int _refreshTick = 0;
  CacheStore? _cache;
  SelectionStore? _selectionStore;

  /// The resolved (mobileSlug, webApp, tenantId) after the picker.
  ({String mobileSlug, String webApp, String tenantId})? _selection;

  /// Access info returned by mobile.access — kept so the selection can be
  /// validated / re-shown without hitting the network again.
  AccessInfo? _access;

  /// True while the async _init / _resolveSelection work is in flight.
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _nodes = NodeRegistry();
    registerBuiltinNodes(_nodes, iconResolver: widget.config.iconResolver);
    if (widget.config.nodes != null) _nodes.registerAll(widget.config.nodes!);
    _templates = TemplateRegistry();
    registerBuiltinTemplates(_templates);
    if (widget.config.templates != null) {
      _templates.registerAll(widget.config.templates!);
    }
    _init();
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    try {
      MobileApi api;
      if (widget.apiOverride != null) {
        api = widget.apiOverride!;
      } else {
        final auth = await _authenticate();
        _auth = auth;
        api = BappMobileApi(auth.apiClient);
      }

      final cache = await _tryCreateCache();
      final store = await SelectionStore.create(host: widget.config.host);

      if (!mounted) return;
      setState(() {
        _api = api;
        _cache = cache;
        _selectionStore = store;
        _loading = true;
      });

      // Fetch access matrix.
      final accessJson = await api.access();
      final access = AccessInfo.fromJson(accessJson);

      if (!mounted) return;
      setState(() => _access = access);

      await _resolveSelection(access);
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _loading = false; });
    }
  }

  /// The distinct apps this build may offer (app-first), each with the tenants
  /// that grant it. Narrowed by [BappMobileConfig.project] / `allowedApps`.
  List<({AccessApp app, List<AccessTenant> tenants})> _allowedAppsFirst(
          AccessInfo access) =>
      access
          .appsFirst()
          .where((e) => widget.config.allowsApp(e.app.slug))
          .toList();

  /// Resolves which (app, tenant) to boot, using persisted selection or the
  /// picker UI. App-first: pick the app, then its tenant. When a selection is
  /// made [_bootSelection] is called. Pickers are skipped whenever the choice
  /// is unambiguous (one app → skip AppPicker; one tenant → boot directly).
  Future<void> _resolveSelection(AccessInfo access) async {
    // 1. Try persisted selection first — still honouring this build's allowlist.
    if (_selectionStore != null) {
      final saved = await _selectionStore!.read();
      if (saved != null && widget.config.allowsApp(saved.mobileSlug)) {
        // Valid if the tenant exists AND that tenant offers an app with the
        // stored mobile slug.
        final valid = access.memberships.any((m) =>
            m.tenant.id == saved.tenantId &&
            m.apps.any((a) => a.slug == saved.mobileSlug));
        if (valid) {
          final membership =
              access.memberships.firstWhere((m) => m.tenant.id == saved.tenantId);
          final app = membership.apps.firstWhere((a) => a.slug == saved.mobileSlug);
          await _bootSelection(app, membership.tenant);
          return;
        }
      }
    }

    // 2. App-first flow.
    final af = _allowedAppsFirst(access);
    if (af.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return; // NoAccessView
    }
    if (af.length == 1) {
      final entry = af.first;
      if (entry.tenants.length == 1) {
        // Single app, single tenant — boot straight to the dashboard.
        await _bootSelection(entry.app, entry.tenants.first);
        return;
      }
      // Single app, multiple tenants — skip AppPicker, show TenantPicker.
      if (mounted) setState(() => _loading = false);
      return;
    }
    // Multiple apps — show AppPicker.
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _bootSelection(AccessApp app, AccessTenant tenant) async {
    // Apply headers (real auth path only — apiOverride path skips this).
    if (_auth != null) {
      _auth!.setApp(app.webApp);
      _auth!.setTenant(tenant.id);
    }

    final sel = (
      mobileSlug: app.slug,
      webApp: app.webApp,
      tenantId: tenant.id,
    );
    await _selectionStore?.save(
        mobileSlug: app.slug, webApp: app.webApp, tenantId: tenant.id);

    if (!mounted) return;
    setState(() {
      _selection = sel;
      _navIndex = null; // start each app on its home screen
      _loading = true;
      _bootstrap = BootstrapService(api: _api!, project: app.slug).load();
      _loading = false;
    });
  }

  // Called when a 403 is detected during boot/screen load.
  Future<void> _resetSelection() async {
    await _selectionStore?.clear();
    if (!mounted) return;
    setState(() {
      _selection = null;
      _bootstrap = null;
      _navIndex = null;
      _loading = true;
    });
    // Re-run selection with the existing access info (avoid another network call).
    if (_access != null) {
      await _resolveSelection(_access!);
    } else {
      await _init();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<CacheStore?> _tryCreateCache() async {
    try {
      final slug = widget.config.project ?? 'app';
      return await CacheStore.create(
          namespace: '${widget.config.host}:$slug');
    } catch (_) {
      return null;
    }
  }

  Future<BappAuth> _authenticate() async {
    final projectOrDefault = widget.config.project ?? 'account';
    final auth = BappAuth(
      config: BappAuthConfig(
        host: widget.config.host,
        app: projectOrDefault,
        clientId: widget.config.clientId ?? projectOrDefault,
        customScheme: widget.config.customScheme,
        ssoAutoLogin: true,
      ),
    );
    await auth.initialize();
    if (!auth.isAuthenticated) {
      await auth.loginWithSSO();
    }
    // Do NOT call setApp here — we set it after selection (with the web_app).
    return auth;
  }

  Color _primary(BootstrapManifest m) {
    final hex = m.app.theme?.primary.replaceAll('#', '');
    if (hex == null || hex.length != 6) return const Color(0xFF1E2A3C);
    final value = int.tryParse('FF$hex', radix: 16);
    return value == null ? const Color(0xFF1E2A3C) : Color(value);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: widget.config.locale,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_error != null) {
      return Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: Text(AppLocalizations.of(ctx).errorWithMessage(_error!)),
          ),
        ),
      );
    }
    if (_loading || _api == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Selection not yet resolved — show picker or no-access.
    if (_selection == null) {
      return _buildSelectionWidget();
    }
    // Selection resolved — show bootstrap shell.
    if (_bootstrap == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return FutureBuilder<BootstrapManifest>(
      future: _bootstrap,
      builder: (context, snap) {
        if (snap.hasError) {
          if (_isForbidden(snap.error!)) {
            // Schedule reset after build.
            WidgetsBinding.instance.addPostFrameCallback((_) => _resetSelection());
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return Scaffold(
              body: Center(
                child: Text(AppLocalizations.of(context)
                    .errorWithMessage('${snap.error}')),
              ));
        }
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return _shell(context, snap.data!);
      },
    );
  }

  /// Builds the appropriate selection widget based on the access matrix state.
  /// App-first: AppPicker → TenantPicker (or auto) → boot. The AppPicker is
  /// skipped when only one app is available; the TenantPicker is skipped when
  /// the chosen app has only one tenant (handled in [_resolveSelection]).
  Widget _buildSelectionWidget() {
    final access = _access;
    if (access == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final af = _allowedAppsFirst(access);
    if (af.isEmpty) return const NoAccessView();

    // Single app — skip the AppPicker, go straight to tenant selection.
    if (af.length == 1) {
      final entry = af.first;
      return TenantPicker(
        tenants: entry.tenants,
        onPick: (tenant) => _bootSelection(entry.app, tenant),
      );
    }

    // Multiple apps — pick the app first, then its tenant (auto if only one).
    return AppPicker(
      apps: af.map((e) => e.app).toList(),
      onPick: (app) {
        final entry = af.firstWhere((e) => e.app.slug == app.slug);
        if (entry.tenants.length == 1) {
          _bootSelection(app, entry.tenants.first);
        } else {
          _navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (_) => TenantPicker(
              tenants: entry.tenants,
              onPick: (tenant) {
                _navigatorKey.currentState?.pop();
                _bootSelection(app, tenant);
              },
            ),
          ));
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Shell / screens
  // ---------------------------------------------------------------------------

  Widget _shell(BuildContext context, BootstrapManifest m) {
    final nav = m.navigation;
    final theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: _primary(m)),
    );

    // No bottom-nav: render the home screen directly (still a full shell).
    if (nav.isEmpty) {
      if (m.home == null) {
        return Scaffold(
            body: Center(child: Text(AppLocalizations.of(context).noScreens)));
      }
      final home = NavItem(key: 'home', label: m.app.name, screen: m.home);
      return Theme(
        data: theme,
        child: ProjectScope(
          project: _selection!.mobileSlug,
          child: Scaffold(
            appBar: AppBar(title: Text(home.label)),
            body: _screen(context, m, home),
          ),
        ),
      );
    }

    // Default to the nav item that points at the backend-defined home screen.
    var homeIdx = 0;
    if (m.home != null) {
      final i = nav.indexWhere((n) => n.screen == m.home);
      if (i >= 0) homeIdx = i;
    }
    final index = (_navIndex ?? homeIdx).clamp(0, nav.length - 1);
    final current = nav[index];
    return Theme(
      data: theme,
      child: ProjectScope(
        project: _selection!.mobileSlug,
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
                          icon: bappIcon(n.icon,
                              resolver: widget.config.iconResolver, size: 24),
                          label: n.label),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _screen(BuildContext context, BootstrapManifest m, NavItem item) {
    final ref = m.screens.firstWhere(
      (s) => s.key == item.screen,
      orElse: () =>
          ScreenRef(key: item.screen ?? '', template: 'list', version: '1'),
    );
    final mobileSlug = _selection!.mobileSlug;
    return FutureBuilder<ScreenDef>(
      key: ValueKey('${ref.key}:$_refreshTick'),
      future: ScreenService(
        api: _api!,
        project: mobileSlug,
        cache: _cache,
      ).load(ref),
      builder: (context, snap) {
        if (snap.hasError) {
          if (_isForbidden(snap.error!)) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _resetSelection());
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
              child: Text(AppLocalizations.of(context)
                  .errorWithMessage('${snap.error}')));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return BappActionDispatcher(
          onAction: _runAction,
          child: BappNavigationDispatcher(
            onNavigate: _navigate,
            child: Builder(
              builder: (c) => _templates.build(c, snap.data!, _api!, _nodes),
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigate(
      Map<String, dynamic> onTap, Map<String, dynamic>? record) async {
    // Present overlay (sheet / dialog / popover) — handle before push logic.
    if (onTap['present'] != null) {
      final ctx = _navigatorKey.currentContext;
      if (ctx == null) return;
      await showPresentOverlay(
        ctx,
        onTap,
        record,
        api: _api!,
        nodes: _nodes,
        project: _selection?.mobileSlug ?? widget.config.project ?? '',
        onAction: _runActionByCode,
        onNavigate: _navigate,
      );
      return;
    }

    final screenKey = onTap['screen'] as String?;
    if (screenKey == null) return;
    final params =
        (onTap['params'] as Map?)?.cast<String, dynamic>() ?? const {};
    String? recordId;
    final pkExpr = params['pk'];
    if (pkExpr is String) {
      final m = RegExp(r'^\$field\((.+)\)$').firstMatch(pkExpr.trim());
      final name = m != null ? m.group(1)!.trim() : pkExpr;
      final v = record?[name] ?? (pkExpr == name ? pkExpr : null);
      recordId = v?.toString();
    }
    if (recordId == null) return;
    if (!mounted) return;
    _navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (_) => DetailScreenView(
        api: _api!,
        nodes: _nodes,
        project: _selection!.mobileSlug,
        screenKey: screenKey,
        recordId: recordId!,
      ),
    ));
  }

  /// Runs an action by task code directly (used by overlay action menus /
  /// buttons that already resolved the code string).
  ///
  /// [extra] carries any device-scan payload (e.g. `{'code': '…'}` from a
  /// scanner node) that should be merged into the task payload.
  Future<void> _runActionByCode(
      String code, Map<String, dynamic>? record,
      [Map<String, dynamic>? extra]) async {
    if (code.isEmpty) return;
    final payload = <String, dynamic>{};
    final id = record?['id'];
    if (id != null) payload['pk'] = id;
    if (extra != null) payload.addAll(extra);
    final result = await ActionRunner(_api!).run(code, payload);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              result.message ?? (result.success ? l10n.done : l10n.failed))),
    );
    if (result.success) {
      setState(() => _refreshTick++);
    }
  }

  Future<void> _runAction(Node button, Map<String, dynamic>? record,
      [Map<String, dynamic>? extra]) async {
    final code = button.props['task'] as String?;
    if (code == null) return;
    await _runActionByCode(code, record, extra);
  }
}
