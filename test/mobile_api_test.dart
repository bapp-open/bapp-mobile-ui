import 'dart:convert';
import 'package:bapp_api_client/bapp_api_client.dart';
import 'package:bapp_mobile_ui/src/api/mobile_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  // ---------------------------------------------------------------------------
  // bootstrap
  // ---------------------------------------------------------------------------
  test('bootstrap POSTs mobile.bootstrap with app= and returns map', () async {
    late http.Request captured;
    final mockClient = MockClient((req) async {
      captured = req;
      return http.Response(
        jsonEncode({
          'version': '1',
          'app': {'slug': 'vault'},
          'navigation': <dynamic>[],
          'screens': <dynamic>[],
          'capabilities': <String, dynamic>{},
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = BappApiClient(
      token: 'test-token',
      host: 'https://test.bapp.ro/api',
      maxRetries: 0,
      httpClient: mockClient,
    );
    final api = BappMobileApi(client);

    final result = await api.bootstrap('vault');

    // URL must reference the task code
    expect(captured.url.toString(), contains('mobile.bootstrap'));
    // Body must contain app=vault
    final body = jsonDecode(captured.body) as Map;
    expect(body['app'], equals('vault'));
    // Method must be POST
    expect(captured.method, equals('POST'));
    // Adapter must return the decoded map
    expect(result['version'], equals('1'));
    expect((result['app'] as Map)['slug'], equals('vault'));
  });

  // ---------------------------------------------------------------------------
  // listIntrospect
  // ---------------------------------------------------------------------------
  test('listIntrospect POSTs mobile.listintrospect with ct= and app=', () async {
    late http.Request captured;
    final mockClient = MockClient((req) async {
      captured = req;
      return http.Response(
        jsonEncode({'fields': <dynamic>[], 'actions': <dynamic>[]}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = BappApiClient(
      token: 'test-token',
      host: 'https://test.bapp.ro/api',
      maxRetries: 0,
      httpClient: mockClient,
    );
    final api = BappMobileApi(client);

    final result = await api.listIntrospect('company_passwords.passwordentry', 'vault');

    expect(captured.url.toString(), contains('mobile.listintrospect'));
    expect(captured.method, equals('POST'));
    final body = jsonDecode(captured.body) as Map;
    expect(body['ct'], equals('company_passwords.passwordentry'));
    expect(body['app'], equals('vault'));
    expect(result, isA<Map<String, dynamic>>());
    expect(result.containsKey('fields'), isTrue);
  });

  // ---------------------------------------------------------------------------
  // screenIntrospect
  // ---------------------------------------------------------------------------
  test('screenIntrospect POSTs mobile.screenintrospect with key= and app=',
      () async {
    late http.Request captured;
    final mockClient = MockClient((req) async {
      captured = req;
      return http.Response(
        jsonEncode({
          'key': 'company_passwords.home',
          'template': 'dashboard',
          'version': '1',
          'node': {'kind': 'column', 'children': <dynamic>[]},
          'actions': <dynamic>[],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final client = BappApiClient(
      token: 'test-token',
      host: 'https://test.bapp.ro/api',
      maxRetries: 0,
      httpClient: mockClient,
    );
    final api = BappMobileApi(client);

    final result =
        await api.screenIntrospect('company_passwords.home', 'vault');

    expect(captured.url.toString(), contains('mobile.screenintrospect'));
    expect(captured.method, equals('POST'));
    final body = jsonDecode(captured.body) as Map;
    expect(body['key'], equals('company_passwords.home'));
    expect(body['app'], equals('vault'));
    expect(result['template'], equals('dashboard'));
  });

  // ---------------------------------------------------------------------------
  // listRecords
  // ---------------------------------------------------------------------------
  test('listRecords GETs content-type endpoint and stringifies int params', () async {
    late http.Request captured;
    final mockClient = MockClient((req) async {
      captured = req;
      return http.Response(
        jsonEncode({
          'results': [
            {'name': 'a'},
            {'name': 'b'},
          ],
          'count': 2,
          'next': null,
          'previous': null,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = BappApiClient(
      token: 'test-token',
      host: 'https://test.bapp.ro/api',
      maxRetries: 0,
      httpClient: mockClient,
    );
    final api = BappMobileApi(client);

    final result = await api.listRecords(
      'company_passwords.passwordentry',
      {'page': 1, 'page_size': 20},
    );

    // URL must reference the content type
    expect(captured.url.toString(), contains('company_passwords.passwordentry'));
    // Must be a GET
    expect(captured.method, equals('GET'));
    // Int params must be stringified as query params
    expect(captured.url.queryParameters['page'], equals('1'));
    expect(captured.url.queryParameters['page_size'], equals('20'));
    // Adapter returns list
    expect(result, hasLength(2));
    expect(result[0]['name'], equals('a'));
    expect(result[1]['name'], equals('b'));
  });

  // ---------------------------------------------------------------------------
  // runAction
  // ---------------------------------------------------------------------------
  test('runAction POSTs the task code with payload and returns map', () async {
    late http.Request captured;
    final mockClient = MockClient((req) async {
      captured = req;
      return http.Response(
        jsonEncode({'success': true}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = BappApiClient(
      token: 'test-token',
      host: 'https://test.bapp.ro/api',
      maxRetries: 0,
      httpClient: mockClient,
    );
    final api = BappMobileApi(client);

    final result = await api.runAction(
      'company_passwords.passwordentry.archive',
      {'id': '42'},
    );

    expect(captured.url.toString(), contains('company_passwords.passwordentry.archive'));
    expect(captured.method, equals('POST'));
    final body = jsonDecode(captured.body) as Map;
    expect(body['id'], equals('42'));
    expect(result, isNotNull);
    expect(result!['success'], isTrue);
  });

  // ---------------------------------------------------------------------------
  // runAction returns null for non-Map responses
  // ---------------------------------------------------------------------------
  test('runAction returns null when server returns non-map JSON', () async {
    final mockClient = MockClient((req) async {
      return http.Response(
        jsonEncode('ok'),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = BappApiClient(
      token: 'test-token',
      host: 'https://test.bapp.ro/api',
      maxRetries: 0,
      httpClient: mockClient,
    );
    final api = BappMobileApi(client);

    final result = await api.runAction('some.action', {'x': '1'});
    expect(result, isNull);
  });

  // ---------------------------------------------------------------------------
  // Structural: BappMobileApi implements MobileApi
  // ---------------------------------------------------------------------------
  test('BappMobileApi is-a MobileApi', () {
    final mockClient = MockClient((_) async => http.Response('{}', 200));
    final client = BappApiClient(httpClient: mockClient);
    final api = BappMobileApi(client);
    expect(api, isA<MobileApi>());
  });
}
