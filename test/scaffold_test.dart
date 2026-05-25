import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contract fixtures are valid json', () {
    for (final f in [
      'mobile.bootstrap.vault.json',
      'mobile.listintrospect.passwordentry.json',
    ]) {
      final data = jsonDecode(File('test/fixtures/$f').readAsStringSync());
      expect(data, isA<Map<String, dynamic>>());
    }
  });
}
