import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';
import 'package:bapp_mobile_ui/src/app/selection_screens.dart';
import 'package:bapp_mobile_ui_example/demo_api.dart';

/// End-to-end smoke test of the runnable demo: it must walk app-first →
/// tenant → dashboard against the in-memory DemoMobileApi.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget demo() => BappMobileApp(
        config: const BappMobileConfig(host: 'https://demo.invalid/api'),
        apiOverride: DemoMobileApi(),
      );

  testWidgets('app-first: AppPicker first; single-tenant app boots its dashboard',
      (t) async {
    await t.pumpWidget(demo());
    await t.pumpAndSettle();

    expect(find.byType(AppPicker), findsOneWidget);
    expect(find.text('Vault'), findsOneWidget);
    expect(find.text('Recepție'), findsOneWidget);

    // Recepție has a single tenant → no tenant picker, straight to its dashboard.
    await t.tap(find.text('Recepție'));
    await t.pumpAndSettle();
    expect(find.byType(TenantPicker), findsNothing);
    expect(find.text('Recepție nouă'), findsWidgets);
  });

  testWidgets('multi-tenant app shows tenant picker then dashboard', (t) async {
    await t.pumpWidget(demo());
    await t.pumpAndSettle();

    await t.tap(find.text('Vault'));
    await t.pumpAndSettle();

    expect(find.byType(TenantPicker), findsOneWidget);
    expect(find.text('ACME SRL'), findsOneWidget);
    expect(find.text('Beta SRL'), findsOneWidget);

    await t.tap(find.text('ACME SRL'));
    await t.pumpAndSettle();
    // Vault has two nav items → bottom nav shell, booted on its home dashboard.
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
