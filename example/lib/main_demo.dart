import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

import 'demo_api.dart';

/// Runnable, backend-free demo of the server-driven flow:
///
///   flutter run -t lib/main_demo.dart
///
/// It boots [DemoMobileApi] (an in-memory fake backend) and walks through
/// app-first selection → tenant selection → the backend-defined default
/// dashboard. No host, login or network required.
///
/// To ship a build limited to a subset of apps (e.g. a reception-only build),
/// pass [BappMobileConfig.allowedApps]; when only one app remains the app
/// picker is skipped:
///
///   config: const BappMobileConfig(host: '…', allowedApps: ['reception']),
///
/// To render licensed Font Awesome Pro glyphs for backend icon names, add the
/// fonts to THIS app's pubspec and pass an `iconResolver` — see
/// `fontawesome_resolver.dart` for a complete, license-safe template:
///
///   config: BappMobileConfig(host: '…', iconResolver: faProResolver),
void main() {
  runApp(
    BappMobileApp(
      config: const BappMobileConfig(host: 'https://demo.invalid/api'),
      apiOverride: DemoMobileApi(),
    ),
  );
}
