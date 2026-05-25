import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

/// Minimal host: the entire UI (navigation, screens, theme, actions) is defined
/// by the backend. Point `host` at your bapp_framework deployment and set
/// `project` to your mobile app slug. Everything else is server-driven.
void main() {
  runApp(
    const BappMobileApp(
      config: BappMobileConfig(
        host: 'https://dev.localapi.ro/api',
        project: 'vault',
      ),
    ),
  );
}
