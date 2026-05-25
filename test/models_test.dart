import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bapp_mobile_ui/src/models/screen.dart';
import 'package:bapp_mobile_ui/src/models/manifest.dart';

Map<String, dynamic> _f(String n) =>
    jsonDecode(File('test/fixtures/$n').readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('ScreenDef parses listintrospect fixture', () {
    final s = ScreenDef.fromJson(_f('mobile.listintrospect.passwordentry.json'));
    expect(s.template, 'list');
    expect(s.key, 'company_passwords.passwordentry:list');
    expect(s.title, 'Passwords');
    expect(s.data!.contentType, 'company_passwords.passwordentry');
    expect(s.data!.method, 'list');
    expect(s.data!.params['page_size'], 30);
    expect(s.node.kind, 'list');
    expect(s.node.children.first.kind, 'card');
    expect(s.node.children.first.children.first.props['name'], 'name');
    expect(s.actions, isEmpty);
  });

  test('BootstrapManifest parses bootstrap fixture', () {
    final m = BootstrapManifest.fromJson(_f('mobile.bootstrap.vault.json'));
    expect(m.version, '1');
    expect(m.app.slug, 'vault');
    expect(m.app.name, 'Vault');
    expect(m.app.webApp, 'erp');
    expect(m.app.theme!.primary, '#1E2A3C');
    expect(m.navigation.first.screen, 'company_passwords.passwordentry:list');
    expect(m.screens.first.key, 'company_passwords.passwordentry:list');
    expect(m.screens.first.template, 'list');
  });
}
