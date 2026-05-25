import 'package:bapp_mobile_ui/src/api/mobile_api.dart';

/// Outcome of running a task action. The app applies `invalidates` (cache
/// eviction + refresh), shows `message`, and follows `navigate` if present.
class ActionResult {
  final bool success;
  final String? message;
  final List<String> invalidates;
  final String? navigate;
  const ActionResult({
    this.success = true,
    this.message,
    this.invalidates = const [],
    this.navigate,
  });

  factory ActionResult.fromResponse(Map<String, dynamic>? res) {
    if (res == null) return const ActionResult();
    final inv = <String>[];
    final raw = res['invalidates'];
    if (raw is List) {
      for (final e in raw) {
        if (e is String) {
          inv.add(e);
        } else if (e is List && e.isNotEmpty) {
          inv.add(e.first.toString()); // server sends [content_type, {filters}]
        }
      }
    }
    return ActionResult(
      success: res['success'] != false,
      message: res['message']?.toString(),
      invalidates: inv,
      navigate: (res['navigate'] ?? res['redirect'])?.toString(),
    );
  }
}

/// Runs a task action through the MobileApi and parses the response.
class ActionRunner {
  final MobileApi api;
  const ActionRunner(this.api);

  Future<ActionResult> run(String code, [Map<String, dynamic>? payload]) async {
    final res = await api.runAction(code, payload ?? const {});
    return ActionResult.fromResponse(res);
  }
}
