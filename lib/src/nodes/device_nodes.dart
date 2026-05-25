import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'package:bapp_mobile_ui/src/actions/action_dispatcher.dart';
import 'package:bapp_mobile_ui/src/models/node.dart';
import 'package:bapp_mobile_ui/src/render/form_scope.dart';
import 'package:bapp_mobile_ui/src/render/node_registry.dart';
import 'package:bapp_mobile_ui/src/render/record_scope.dart';

// ---------------------------------------------------------------------------
// Public registration entry-point
// ---------------------------------------------------------------------------

/// Registers the 5 device-feature node kinds into [registry].
void registerDeviceNodes(NodeRegistry registry) {
  registry.register('scanner-button', (c, n) => _ScannerButtonNode(node: n));
  registry.register('scanner-stream', (c, n) => _ScannerStreamNode(node: n));
  registry.register('nfc-button', (c, n) => _NfcButtonNode(node: n));
  registry.register('nfc-stream', (c, n) => _NfcStreamNode(node: n));
  registry.register('connectivity', (c, n) => _ConnectivityNode(node: n));
}

// ---------------------------------------------------------------------------
// Shared delivery helper
// ---------------------------------------------------------------------------

/// Writes [value] into the form field named [field] (if set) and dispatches
/// the task action named [action] (if set) with [payloadKey] → [value].
void _deliver(
  BuildContext context,
  Node sourceNode, {
  required String value,
  required String payloadKey,
}) {
  final field = sourceNode.props['field'] as String?;
  final action = sourceNode.props['action'] as String?;

  if (field != null && field.isNotEmpty) {
    FormScope.of(context)?.setValue(field, value);
  }

  if (action != null && action.isNotEmpty) {
    final dispatcher = BappActionDispatcher.of(context);
    if (dispatcher != null) {
      final record = RecordScope.of(context);
      final taskNode = Node(
        kind: 'button',
        props: {'kind': 'task', 'task': action},
      );
      dispatcher.onAction(taskNode, record, {payloadKey: value});
    }
  }
}

// ---------------------------------------------------------------------------
// Format helpers  (mirrored from reference app's native/scanner.dart)
// ---------------------------------------------------------------------------

List<BarcodeFormat>? _parseFormats(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final out = <BarcodeFormat>[];
  for (final tok in raw.split(',')) {
    final f = _formatFromName(tok.trim().toLowerCase());
    if (f != null) out.add(f);
  }
  return out.isEmpty ? null : out;
}

BarcodeFormat? _formatFromName(String name) {
  switch (name) {
    case 'qr':
    case 'qrcode':
      return BarcodeFormat.qrCode;
    case 'ean13':
      return BarcodeFormat.ean13;
    case 'ean8':
      return BarcodeFormat.ean8;
    case 'code128':
      return BarcodeFormat.code128;
    case 'code39':
      return BarcodeFormat.code39;
    case 'code93':
      return BarcodeFormat.code93;
    case 'upce':
      return BarcodeFormat.upcE;
    case 'upca':
      return BarcodeFormat.upcA;
    case 'pdf417':
      return BarcodeFormat.pdf417;
    case 'datamatrix':
    case 'data-matrix':
      return BarcodeFormat.dataMatrix;
    case 'aztec':
      return BarcodeFormat.aztec;
    case 'itf':
    case 'itf14':
      return BarcodeFormat.itf14;
    case 'codabar':
      return BarcodeFormat.codabar;
    default:
      return null;
  }
}

// ---------------------------------------------------------------------------
// scanner-button
// ---------------------------------------------------------------------------

class _ScannerButtonNode extends StatelessWidget {
  const _ScannerButtonNode({required this.node});
  final Node node;

  @override
  Widget build(BuildContext context) {
    final label = (node.props['label'] as String?) ?? 'Scan';
    final formats = _parseFormats(node.props['formats'] as String?);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FilledButton.icon(
        icon: const Icon(Icons.qr_code_scanner_outlined, size: 18),
        label: Text(label),
        onPressed: () => _onPressed(context, formats),
      ),
    );
  }

  Future<void> _onPressed(
      BuildContext context, List<BarcodeFormat>? formats) async {
    String? scanned;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => SizedBox(
        height: 320,
        child: _OneShotScanner(
          formats: formats,
          onDetected: (code) {
            scanned = code;
            Navigator.of(sheetCtx).pop();
          },
        ),
      ),
    );
    if (scanned == null || !context.mounted) return;
    _deliver(context, node, value: scanned!, payloadKey: 'code');
  }
}

/// Single-use scanner widget embedded inside a bottom sheet.
/// On first successful detection it calls [onDetected] and the
/// caller is responsible for popping the sheet.
class _OneShotScanner extends StatefulWidget {
  const _OneShotScanner({required this.onDetected, this.formats});
  final void Function(String code) onDetected;
  final List<BarcodeFormat>? formats;

  @override
  State<_OneShotScanner> createState() => _OneShotScannerState();
}

class _OneShotScannerState extends State<_OneShotScanner> {
  late final MobileScannerController _ctrl;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // Empty list == "all formats" per mobile_scanner v7 convention (same as
    // reference app's native/scanner.dart _OneShotScannerScreen.initState).
    _ctrl = MobileScannerController(
      formats: widget.formats ?? const <BarcodeFormat>[],
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // BarcodeCapture API used verbatim from reference scanner_nodes.dart
  // _ScannerStreamNodeState._onDetect and native/scanner.dart _onDetect.
  void _onDetect(BarcodeCapture cap) {
    if (_done) return;
    for (final b in cap.barcodes) {
      final v = b.rawValue;
      if (v == null || v.isEmpty) continue;
      _done = true;
      widget.onDetected(v);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(controller: _ctrl, onDetect: _onDetect);
  }
}

// ---------------------------------------------------------------------------
// scanner-stream
// ---------------------------------------------------------------------------

class _ScannerStreamNode extends StatefulWidget {
  const _ScannerStreamNode({required this.node});
  final Node node;

  @override
  State<_ScannerStreamNode> createState() => _ScannerStreamNodeState();
}

class _ScannerStreamNodeState extends State<_ScannerStreamNode> {
  late final MobileScannerController _ctrl;
  // Dedupe: track last-seen time per (value|format) key.
  final Map<String, DateTime> _recent = {};
  static const _dedupeWindow = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    final formats =
        _parseFormats(widget.node.props['formats'] as String?);
    _ctrl = MobileScannerController(
      formats: formats ?? const <BarcodeFormat>[],
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // onDetect / BarcodeCapture API from reference scanner_nodes.dart
  void _onDetect(BarcodeCapture cap) {
    if (!mounted) return;
    final now = DateTime.now().toUtc();
    for (final b in cap.barcodes) {
      final v = b.rawValue;
      if (v == null || v.isEmpty) continue;
      final key = '$v|${b.format.name}';
      final last = _recent[key];
      if (last != null && now.difference(last) < _dedupeWindow) continue;
      _recent[key] = now;
      // Prune stale entries lazily.
      _recent.removeWhere((_, t) => now.difference(t) > _dedupeWindow * 6);
      _deliver(context, widget.node, value: v, payloadKey: 'code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 240,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: MobileScanner(controller: _ctrl, onDetect: _onDetect),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NFC tag extraction helpers (ported from reference nfc_nodes.dart)
// ---------------------------------------------------------------------------

/// Extracts a stable string identifier from an [NfcTag] using dynamic
/// dispatch — same technique as reference nfc_nodes.dart _extractTag().
String? _extractTagId(NfcTag tag) {
  final d = (tag as dynamic).data;

  // Android: top-level `id` is a Uint8List.
  try {
    final raw = d.id;
    if (raw is List<int>) return _hex(raw);
  } catch (_) {}

  // iOS / fallback: walk per-tech subobjects for an `identifier`.
  for (final field in const [
    'nfcA', 'mifareClassic', 'mifareUltralight', 'isoDep',
    'iso7816', 'miFare', 'iso15693', 'feliCa', 'nfcB', 'nfcF', 'nfcV',
  ]) {
    final sub = _readDynField(d, field);
    if (sub == null) continue;
    try {
      final ident = (sub as dynamic).identifier;
      if (ident is List<int> && ident.isNotEmpty) return _hex(ident);
    } catch (_) {}
  }

  // Last resort: plugin opaque handle (always present in nfc_manager v4).
  try {
    final h = (tag as dynamic).handle;
    if (h != null) return h.toString();
  } catch (_) {}

  return null;
}

Object? _readDynField(dynamic obj, String name) {
  try {
    switch (name) {
      case 'nfcA': return obj.nfcA;
      case 'nfcB': return obj.nfcB;
      case 'nfcF': return obj.nfcF;
      case 'nfcV': return obj.nfcV;
      case 'isoDep': return obj.isoDep;
      case 'mifareClassic': return obj.mifareClassic;
      case 'mifareUltralight': return obj.mifareUltralight;
      case 'miFare': return obj.miFare;
      case 'iso7816': return obj.iso7816;
      case 'iso15693': return obj.iso15693;
      case 'feliCa': return obj.feliCa;
    }
  } catch (_) {}
  return null;
}

String _hex(List<int> bytes) {
  final b = StringBuffer();
  for (final x in bytes) {
    b.write((x & 0xff).toRadixString(16).padLeft(2, '0'));
  }
  return b.toString();
}

// NFC session polling options — same set as reference nfc_nodes.dart.
const _kPollingOptions = {
  NfcPollingOption.iso14443,
  NfcPollingOption.iso15693,
  NfcPollingOption.iso18092,
};

// ---------------------------------------------------------------------------
// nfc-button
// ---------------------------------------------------------------------------

class _NfcButtonNode extends StatelessWidget {
  const _NfcButtonNode({required this.node});
  final Node node;

  @override
  Widget build(BuildContext context) {
    final label = (node.props['label'] as String?) ?? 'Read NFC tag';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FilledButton.icon(
        icon: const Icon(Icons.nfc_outlined, size: 18),
        label: Text(label),
        onPressed: () => _onPressed(context),
      ),
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    // checkAvailability() API from reference nfc_nodes.dart NfcButtonNode
    // and _NfcStreamNodeState.initState.
    final avail = await NfcManager.instance.checkAvailability();
    if (!context.mounted) return;
    if (avail != NfcAvailability.enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC unavailable on this device')),
      );
      return;
    }

    String? tagId;
    bool cancelled = false;

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetCtx) {
        bool done = false;
        Timer? timeout;

        Future<void> finish({String? id, bool cancel = false}) async {
          if (done) return;
          done = true;
          timeout?.cancel();
          try {
            await NfcManager.instance.stopSession();
          } catch (_) {}
          tagId = id;
          cancelled = cancel;
          if (sheetCtx.mounted && Navigator.of(sheetCtx).canPop()) {
            Navigator.of(sheetCtx).pop();
          }
        }

        // Start NFC session — API from reference nfc_nodes.dart _readOnce().
        NfcManager.instance.startSession(
          pollingOptions: _kPollingOptions,
          onDiscovered: (NfcTag tag) async {
            final id = _extractTagId(tag);
            await finish(id: id, cancel: id == null);
          },
        ).catchError((Object _) async {
          await finish(cancel: true);
        });

        timeout = Timer(
          const Duration(seconds: 30),
          () => finish(cancel: true),
        );

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.nfc_outlined, size: 48),
                const SizedBox(height: 12),
                const Text('Hold a tag near the device',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Times out in 30s',
                    style:
                        TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => finish(cancel: true),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (cancelled || tagId == null || !context.mounted) return;
    _deliver(context, node, value: tagId!, payloadKey: 'tag');
  }
}

// ---------------------------------------------------------------------------
// nfc-stream
// ---------------------------------------------------------------------------

class _NfcStreamNode extends StatefulWidget {
  const _NfcStreamNode({required this.node});
  final Node node;

  @override
  State<_NfcStreamNode> createState() => _NfcStreamNodeState();
}

class _NfcStreamNodeState extends State<_NfcStreamNode> {
  /// null = probing, true = session active, false = unavailable.
  bool? _available;
  bool _sessionStarted = false;
  static const _dedupeWindow = Duration(seconds: 5);
  final Map<String, DateTime> _recent = {};

  @override
  void initState() {
    super.initState();
    // Defer so context is safe — mirrors reference nfc_nodes.dart initState.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final avail = await NfcManager.instance.checkAvailability();
      if (!mounted) return;
      final enabled = avail == NfcAvailability.enabled;
      setState(() => _available = enabled);
      if (!enabled) return;
      try {
        // startSession API from reference nfc_nodes.dart _NfcStreamNodeState.
        await NfcManager.instance.startSession(
          pollingOptions: _kPollingOptions,
          onDiscovered: _onDiscovered,
        );
        _sessionStarted = true;
      } catch (_) {
        if (mounted) setState(() => _available = false);
      }
    });
  }

  @override
  void dispose() {
    if (_sessionStarted) {
      // Fire-and-forget — same pattern as reference nfc_nodes.dart dispose().
      unawaited(NfcManager.instance.stopSession());
    }
    super.dispose();
  }

  Future<void> _onDiscovered(NfcTag tag) async {
    if (!mounted) return;
    final id = _extractTagId(tag);
    if (id == null) return;
    final now = DateTime.now().toUtc();
    final last = _recent[id];
    if (last != null && now.difference(last) < _dedupeWindow) return;
    _recent[id] = now;
    _recent.removeWhere((_, t) => now.difference(t) > _dedupeWindow * 6);
    _deliver(context, widget.node, value: id, payloadKey: 'tag');
  }

  @override
  Widget build(BuildContext context) {
    final available = _available;
    if (available == false) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Card(
          child: ListTile(
            leading: Icon(Icons.nfc_outlined, color: Colors.black54),
            title: Text('NFC not available on this device'),
            subtitle: Text(
              'This device does not expose an NFC reader, or the '
              'reader is held by another app.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              available == null
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.nfc_outlined, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hold a tag near the device',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text(
                      'Reading continuously…',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// connectivity
// ---------------------------------------------------------------------------

class _ConnectivityNode extends StatefulWidget {
  const _ConnectivityNode({required this.node});
  final Node node;

  @override
  State<_ConnectivityNode> createState() => _ConnectivityNodeState();
}

class _ConnectivityNodeState extends State<_ConnectivityNode> {
  // Seed with null until checkConnectivity resolves.
  List<ConnectivityResult>? _results;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // checkConnectivity() returns List<ConnectivityResult> in connectivity_plus
    // v7 — same API used in reference scanner_nodes.dart / nfc_nodes.dart
    // where onConnectivityChanged emits List<ConnectivityResult>.
    final initial = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() => _results = initial);

    // onConnectivityChanged emits List<ConnectivityResult> in v7 —
    // confirmed by reference nfc_nodes.dart and scanner_nodes.dart usage:
    //   _connSub = Connectivity().onConnectivityChanged.listen((results) {
    //     final online = results.any((r) => r != ConnectivityResult.none);
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) setState(() => _results = results);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get _online {
    final r = _results;
    if (r == null) return false;
    return r.any((x) => x != ConnectivityResult.none);
  }

  @override
  Widget build(BuildContext context) {
    final onlineLabel =
        (widget.node.props['online_label'] as String?) ?? 'Online';
    final offlineLabel =
        (widget.node.props['offline_label'] as String?) ?? 'Offline';

    final online = _online;
    return Chip(
      avatar: Icon(
        Icons.circle,
        size: 12,
        color: online ? Colors.green : Colors.grey,
      ),
      label: Text(online ? onlineLabel : offlineLabel),
      visualDensity: VisualDensity.compact,
    );
  }
}
