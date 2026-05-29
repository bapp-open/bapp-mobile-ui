import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

import 'demo_api.dart';
import 'embedded_icons_resolver.dart';

/// Runnable demo of an **embedded icon font** driving the backend-defined UI:
///
///   flutter run -t lib/main_icons.dart --no-tree-shake-icons
///
/// The backend sends icon names (`fa-house`, `fa-key`, …); [cupertinoEmbeddedResolver]
/// maps them onto the bundled Cupertino font so they render from a real shipped
/// font — the same path you'd use for a licensed Font Awesome Pro `.otf`.
///
/// `allowedApps: ['reception']` makes this a single-app build that boots
/// straight into the Recepție dashboard, whose tiles show the embedded glyphs.
void main() {
  runApp(
    BappMobileApp(
      config: BappMobileConfig(
        host: 'https://demo.invalid/api',
        allowedApps: const ['reception'],
        iconResolver: cupertinoEmbeddedResolver,
      ),
      apiOverride: DemoMobileApi(),
    ),
  );
}
