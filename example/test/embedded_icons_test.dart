import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';
import 'package:bapp_mobile_ui_example/demo_api.dart';
import 'package:bapp_mobile_ui_example/embedded_icons_resolver.dart';

/// Proves the embed→resolve path: backend `fa-*` icon names render from the
/// bundled Cupertino font (standing in for a licensed Font Awesome Pro .otf).
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('embedded font resolves backend fa- icon names end-to-end',
      (t) async {
    await t.pumpWidget(BappMobileApp(
      config: BappMobileConfig(
        host: 'https://demo.invalid/api',
        allowedApps: const ['reception'], // single-app → boots its dashboard
        iconResolver: cupertinoEmbeddedResolver,
      ),
      apiOverride: DemoMobileApi(),
    ));
    await t.pumpAndSettle();

    // The Recepție dashboard tiles (fa-plus, fa-list) now render glyphs from
    // the embedded Cupertino font — not the SDK's Material fallback.
    final icons = t.widgetList<Icon>(find.byType(Icon));
    expect(
      icons.any((i) => i.icon?.fontFamily == 'CupertinoIcons'),
      isTrue,
      reason: 'expected at least one icon rendered from the embedded font',
    );
  });

  test('resolver maps a known fa- name to the embedded font family', () {
    final widget = cupertinoEmbeddedResolver('fa-house');
    expect(widget, isA<Icon>());
    expect((widget as Icon).icon!.fontFamily, 'CupertinoIcons');
  });
}
