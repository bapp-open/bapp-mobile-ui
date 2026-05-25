import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

Map<String, dynamic> _f(String n) =>
    jsonDecode(File('test/fixtures/$n').readAsStringSync()) as Map<String, dynamic>;

class FixtureApi implements MobileApi {
  @override
  Future<Map<String, dynamic>> bootstrap(String project) async =>
      _f('mobile.bootstrap.vault.json');
  @override
  Future<Map<String, dynamic>> listIntrospect(String ct, String project) async =>
      _f('mobile.listintrospect.passwordentry.json');
  @override
  Future<List<Map<String, dynamic>>> listRecords(
          String ct, Map<String, dynamic> params) async =>
      [
        {'id': 1, 'name': 'Gmail', 'username': 'a@example.com'},
        {'id': 2, 'name': 'GitHub', 'username': 'b@example.com'},
      ];
  @override
  Future<Map<String, dynamic>?> runAction(
          String code, Map<String, dynamic> payload) async =>
      {'success': true, 'message': 'ok'};
}

void main() {
  testWidgets('BappMobileApp boots, shows nav + renders list from fixtures',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: const BappMobileConfig(
          host: 'https://example.test/api', project: 'vault'),
      apiOverride: FixtureApi(),
    ));
    await t.pumpAndSettle();

    expect(find.text('Passwords'), findsWidgets); // app bar title (nav label)
    expect(find.text('Gmail'), findsOneWidget);
    expect(find.text('a@example.com'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
  });
}
