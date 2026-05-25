import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

/// Minimal host: the entire UI (navigation, screens, theme, actions) is defined
/// by the backend. Point [BappMobileConfig.host] at your bapp_framework
/// deployment and set [BappMobileConfig.project] to your mobile app slug
/// (leave it empty to get the app-first picker).
///
/// For local testing without committing your backend details, override these
/// via a gitignored dart-define file:
///
///   flutter run --dart-define-from-file=bapp_dev.json
///
/// where `bapp_dev.json` (see `bapp_dev.example.json`) contains e.g.
///   { "BAPP_HOST": "https://panel.bapp.ro/api", "BAPP_PROJECT": "", "BAPP_CLIENT_ID": "" }
void main() {
  const host = String.fromEnvironment(
    'BAPP_HOST',
    defaultValue: 'https://dev.localapi.ro/api',
  );
  const project = String.fromEnvironment('BAPP_PROJECT');
  const clientId = String.fromEnvironment('BAPP_CLIENT_ID');
  const scheme = String.fromEnvironment('BAPP_SCHEME');

  runApp(
    BappMobileApp(
      config: BappMobileConfig(
        host: host,
        project: project.isEmpty ? null : project,
        clientId: clientId.isEmpty ? null : clientId,
        customScheme: scheme.isEmpty ? null : scheme,
      ),
    ),
  );
}
