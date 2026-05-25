import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapp_mobile_ui/src/cache/cache_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('put then get returns value for matching version', () async {
    final c = await CacheStore.create(namespace: 'h:p:t');
    await c.putJson('bootstrap', '1', {'a': 1});
    expect(await c.getJson('bootstrap', '1'), {'a': 1});
  });

  test('get returns null when version differs', () async {
    final c = await CacheStore.create(namespace: 'h:p:t');
    await c.putJson('bootstrap', '1', {'a': 1});
    expect(await c.getJson('bootstrap', '2'), isNull);
  });

  test('invalidate removes the entry', () async {
    final c = await CacheStore.create(namespace: 'h:p:t');
    await c.putJson('screen', '1', {'x': 'y'});
    await c.invalidate('screen');
    expect(await c.getJson('screen', '1'), isNull);
  });

  test('namespacing isolates entries', () async {
    final a = await CacheStore.create(namespace: 'h:p:t1');
    final b = await CacheStore.create(namespace: 'h:p:t2');
    await a.putJson('bootstrap', '1', {'who': 'a'});
    expect(await b.getJson('bootstrap', '1'), isNull);
  });
}
