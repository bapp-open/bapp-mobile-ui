import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

/// An in-memory [MobileApi] that fakes a bapp_framework backend so the example
/// runs with no server. It returns the same response shapes the real
/// `mobile.*` tasks produce, exercising the full flow:
///
///   login → access matrix → APP picker → TENANT picker → default dashboard.
///
/// The account below can reach two apps; "Vault" lives in two tenants and
/// "Recepție" in one — so picking Vault shows the tenant picker while picking
/// Recepție boots straight into its dashboard.
class DemoMobileApi implements MobileApi {
  @override
  Future<Map<String, dynamic>> access() async => {
        'user': {'sub': 'u1', 'email': 'demo@bapp.ro', 'name': 'Demo User'},
        'memberships': [
          {
            'tenant': {'id': 't1', 'name': 'ACME SRL'},
            'apps': [_vaultApp, _receptionApp],
          },
          {
            'tenant': {'id': 't2', 'name': 'Beta SRL'},
            'apps': [_vaultApp],
          },
        ],
      };

  static const _vaultApp = {
    'slug': 'vault',
    'name': 'Vault',
    'icon': 'fa-shield-keyhole',
    'web_app': 'erp',
  };
  static const _receptionApp = {
    'slug': 'reception',
    'name': 'Recepție',
    'icon': 'fa-truck-ramp-box',
    'web_app': 'ordermanager',
  };

  @override
  Future<Map<String, dynamic>> bootstrap(String project) async {
    if (project == 'reception') {
      // Single-screen app: no bottom nav, boots directly into the dashboard.
      return {
        'version': '1',
        'app': {
          ..._receptionApp,
          'theme': {'primary': '#1E7A46', 'mode': 'light'},
        },
        'home': 'reception.home',
        'navigation': [
          {'key': 'home', 'label': 'Acasă', 'icon': 'fa-house', 'screen': 'reception.home'},
        ],
        'screens': [
          {'key': 'reception.home', 'template': 'dashboard', 'version': '1'},
        ],
        'capabilities': {},
      };
    }
    return {
      'version': '1',
      'app': {
        ..._vaultApp,
        'theme': {'primary': '#1E2A3C', 'mode': 'light'},
      },
      'home': 'vault.home',
      'navigation': [
        {'key': 'home', 'label': 'Acasă', 'icon': 'fa-house', 'screen': 'vault.home'},
        {'key': 'list', 'label': 'Passwords', 'icon': 'fa-key', 'screen': 'vault.list'},
      ],
      'screens': [
        {'key': 'vault.home', 'template': 'dashboard', 'version': '1'},
        {'key': 'vault.list', 'template': 'list', 'version': '1'},
      ],
      'capabilities': {},
    };
  }

  @override
  Future<Map<String, dynamic>> screenIntrospect(String key, String project) async {
    if (key == 'reception.home') {
      return _dashboard(key, 'Recepție', [
        _tile('Recepție nouă', 'fa-plus'),
        _tile('Recepții', 'fa-list'),
      ]);
    }
    return _dashboard(key, 'Acasă', [
      _tile('Passwords', 'fa-key'),
      _tile('Setări', 'fa-gear'),
    ]);
  }

  @override
  Future<Map<String, dynamic>> listIntrospect(String contentType, String project) async => {
        'key': 'vault.list',
        'template': 'list',
        'title': 'Passwords',
        'version': '1',
        'data': {
          'source': 'content_type',
          'content_type': 'demo.password',
          'method': 'list',
          'params': {'page_size': 30},
        },
        'node': {
          'kind': 'list',
          'props': {'page_size': 30},
          'children': [
            {
              'kind': 'card',
              'children': [
                {'kind': 'field', 'props': {'name': 'name', 'widget': 'title'}},
                {'kind': 'field', 'props': {'name': 'username', 'widget': 'subtitle'}},
              ],
              'on_tap': {
                'kind': 'navigate',
                'screen': 'vault.detail',
                'params': {'pk': '\$field(id)'},
              },
            },
          ],
        },
        'actions': [],
      };

  @override
  Future<Map<String, dynamic>> detailIntrospect(String contentType, String project) async => {
        'key': 'vault.detail',
        'template': 'detail',
        'title': 'Password',
        'version': '1',
        'data': {
          'source': 'content_type',
          'content_type': 'demo.password',
          'method': 'get',
        },
        'node': {
          'kind': 'column',
          'children': [
            {'kind': 'field', 'props': {'name': 'name', 'widget': 'title'}},
            {'kind': 'field', 'props': {'name': 'username', 'widget': 'subtitle'}},
            {'kind': 'field', 'props': {'name': 'url'}},
          ],
        },
        'actions': [],
      };

  @override
  Future<List<Map<String, dynamic>>> listRecords(
          String contentType, Map<String, dynamic> params) async =>
      [
        {'id': 1, 'name': 'Gmail', 'username': 'demo@gmail.com', 'url': 'https://gmail.com'},
        {'id': 2, 'name': 'GitHub', 'username': 'demo@github.com', 'url': 'https://github.com'},
      ];

  @override
  Future<Map<String, dynamic>?> getRecord(String contentType, String id) async => {
        'id': id,
        'name': 'Gmail',
        'username': 'demo@gmail.com',
        'url': 'https://gmail.com',
      };

  @override
  Future<Map<String, dynamic>?> runAction(
          String code, Map<String, dynamic> payload) async =>
      {'success': true, 'message': 'Done (demo)'};

  // --- helpers ---------------------------------------------------------------

  Map<String, dynamic> _dashboard(String key, String title, List<Map<String, dynamic>> tiles) => {
        'key': key,
        'template': 'dashboard',
        'title': title,
        'version': '1',
        'data': null,
        'node': {'kind': 'column', 'children': tiles},
        'actions': [],
      };

  Map<String, dynamic> _tile(String label, String icon) => {
        'kind': 'tile',
        'props': {'label': label, 'icon': icon},
      };
}
