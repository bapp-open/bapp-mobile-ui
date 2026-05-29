import 'package:flutter/cupertino.dart';
import 'package:bapp_mobile_ui/bapp_mobile_ui.dart';

/// A WORKING, runnable demonstration of the "embed a font so it ships" path.
///
/// This package can't legally bundle Font Awesome Pro, so the demo embeds the
/// freely-redistributable **Cupertino** icon font instead (it ships inside the
/// app via the `cupertino_icons` dependency — exactly like an embedded .otf).
/// It maps the backend's `fa-*` icon names onto that embedded font's glyphs
/// using the SDK's [fontIconResolver], proving the whole mechanism end-to-end.
///
/// To do the same with your licensed Font Awesome Pro font: embed the `.otf`
/// in your app's pubspec and swap the family + codepoints — see
/// `fontawesome_resolver.dart`. (Build with `--no-tree-shake-icons`, since
/// glyphs are selected at runtime.)
///
/// `fontIconResolver` strips the `fa-` prefix before lookup, so backend names
/// like `fa-house` resolve via the `'house'` key below.
final IconResolver cupertinoEmbeddedResolver = fontIconResolver(
  fontFamily: 'CupertinoIcons',
  fontPackage: 'cupertino_icons',
  glyphs: {
    'house': CupertinoIcons.house.codePoint,
    'gear': CupertinoIcons.gear.codePoint,
    'key': CupertinoIcons.lock_fill.codePoint,
    'list': CupertinoIcons.list_bullet.codePoint,
    'plus': CupertinoIcons.add.codePoint,
    'shield-keyhole': CupertinoIcons.shield.codePoint,
    'truck-ramp-box': CupertinoIcons.cube_box.codePoint,
    'circle-info': CupertinoIcons.info.codePoint,
  },
);
