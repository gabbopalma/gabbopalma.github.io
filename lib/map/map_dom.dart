import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// The few places where the map needs the browser rather than Flutter.

/// Resolves [path] against the page's `<base href>`, into an absolute URL.
///
/// The plugin loads maplibre-gl-js with a dynamic `import()`, and a relative
/// specifier there resolves against the URL of the script doing the import,
/// not against the page. In a release build that script happens to sit at the
/// site root, so `./maplibre/...` works by accident. Under `jaspr serve` it
/// lives in `/packages/build_web_compilers/...`, and the same path is a 404.
/// The base is also what keeps `/it/` pointing at the root copy.
String siteUrl(String path) => Uri.parse(web.document.baseURI).resolve(path).toString();

/// Keeps the map canvas out of the tab order.
///
/// MapLibre GL JS gives its canvas `tabindex="0"` so the map can be driven by
/// keyboard. On this page the map is scenery: every gesture is off, so a
/// keyboard user tabbing through the links would land on an element that
/// does nothing.
void releaseMapCanvasFocus() {
  final canvases = web.document.querySelectorAll('canvas.maplibregl-canvas');
  for (var i = 0; i < canvases.length; i++) {
    (canvases.item(i) as web.Element?)?.removeAttribute('tabindex');
  }
}

/// Whether the page is in its phone layout, the map a band across the top.
/// The same breakpoint as `@media (max-width: 900px)` in the stylesheet.
bool isBandLayout() => web.window.innerWidth <= 900;

/// Sets the pointer over the map: a hand where the globe can be grabbed, a
/// closed hand while it is, the plain arrow everywhere else.
void setCanvasCursor(JSObject container, String cursor) {
  (container as web.HTMLElement).style.cursor = cursor;
}

/// Hides the map until its first composition is in place, then fades it in.
///
/// The plugin creates the map centred, and the hero globe is pushed right by
/// camera padding that can only be set once the camera is reachable. Without
/// this the globe would appear in the middle and jump.
void showMapCanvas({required bool visible}) {
  final canvases = web.document.querySelectorAll('canvas.maplibregl-canvas');
  for (var i = 0; i < canvases.length; i++) {
    final canvas = canvases.item(i) as web.HTMLCanvasElement?;
    if (canvas == null) continue;
    canvas.style.opacity = visible ? '1' : '0';
  }
}

/// Gives the globe a shadow on the page, drawn by the browser.
///
/// GL JS cannot: its atmosphere is coloured by physics, not by the style,
/// and on a light page it melts the edge of the sphere into the background.
/// With the sky transparent the canvas is clear everywhere but the sphere,
/// so a CSS `drop-shadow` follows its outline exactly and costs Dart nothing.
/// Taken off for the flat maps, which are opaque edge to edge and would get
/// a frame instead. Same trick as the Berlin deck.
void shadeGlobe({required bool on}) {
  final canvases = web.document.querySelectorAll('canvas.maplibregl-canvas');
  for (var i = 0; i < canvases.length; i++) {
    final canvas = canvases.item(i) as web.HTMLCanvasElement?;
    if (canvas == null) continue;
    canvas.style.filter = on
        ? 'drop-shadow(0 0 2px rgba(17, 23, 37, 0.30)) '
              'drop-shadow(0 18px 36px rgba(17, 23, 37, 0.18))'
        : '';
    canvas.style.transition = 'filter 700ms ease, opacity 500ms ease';
  }
}
