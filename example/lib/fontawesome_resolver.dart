import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

/// Sample [IconResolver] that renders backend icon names (e.g. `'fa-key'`)
/// using Font Awesome **Pro** glyphs the app **embeds** in its own bundle.
///
/// ─────────────────────────────────────────────────────────────────────────
/// LICENSE-SAFE BY DESIGN
/// ─────────────────────────────────────────────────────────────────────────
/// `bapp_mobile_ui` ships NO Font Awesome assets — it only knows icon *name
/// strings*. The licensed font files are embedded ONLY in YOUR app (declared
/// in this app's own `pubspec.yaml`), so they ship inside your build and are
/// never redistributed through the shared SDK. The Pro license is respected.
///
/// ─────────────────────────────────────────────────────────────────────────
/// 1. EMBED THE FONT FILES (copy from your Pro kit into THIS app, not the SDK)
/// ─────────────────────────────────────────────────────────────────────────
///   assets/fonts/FontAwesome6Pro-Solid.otf
///   assets/fonts/FontAwesome6Brands-Regular.otf
///
/// 2. DECLARE THEM IN THIS APP'S pubspec.yaml so they ship in the binary:
///   flutter:
///     fonts:
///       - family: Font Awesome 6 Pro
///         fonts:
///           - asset: assets/fonts/FontAwesome6Pro-Solid.otf
///             weight: 900
///       - family: Font Awesome 6 Brands
///         fonts:
///           - asset: assets/fonts/FontAwesome6Brands-Regular.otf
///
/// 3. WIRE IT UP (build with `--no-tree-shake-icons` since glyphs are picked
///    at runtime):
///   BappMobileApp(
///     config: BappMobileConfig(host: '…', iconResolver: faProResolver),
///   );
///
/// Codepoints below are an illustrative seed — generate the full name→unicode
/// maps from your kit's `metadata/icons.json` (the `unicode` field). Names
/// arrive with the `fa-` prefix, which the resolver strips automatically.
const Map<String, int> _faSolid = {
  'key': 0xf084,
  'gear': 0xf013,
  'house': 0xf015,
  'list': 0xf03a,
  'plus': 0x2b,
  'circle-info': 0xf05a,
  'shield-halved': 0xf3ed,
  'truck-ramp-box': 0xf4de,
};

const Map<String, int> _faBrands = {
  'github': 0xf09b,
  'google': 0xf1a0,
};

/// Drop this into `BappMobileConfig.iconResolver`. Solid is tried first, then
/// Brands; unmapped names fall back to the SDK's Material icons.
final IconResolver faProResolver = combineIconResolvers([
  fontIconResolver(fontFamily: 'Font Awesome 6 Pro', glyphs: _faSolid),
  fontIconResolver(fontFamily: 'Font Awesome 6 Brands', glyphs: _faBrands),
]);
