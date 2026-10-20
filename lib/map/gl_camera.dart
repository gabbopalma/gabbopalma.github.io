import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;

/// The GL JS map behind the plugin, used for one thing only: the camera.
///
/// maplibre_gl's `animateCamera` takes a target and a duration. On the web it
/// becomes a `flyTo` with GL JS's own curve, and there is no way to pass
/// camera padding or an easing. The site needs both: the hero globe sits half
/// out of the frame because of padding, and a guided transition is a matter
/// of easing. Until the plugin grows those options, the page drives GL JS
/// directly for camera moves and leaves everything else (the widget, the
/// style, the layers) to the plugin.
extension type GlMap._(JSObject _) implements JSObject {
  external void easeTo(JSObject options);
  external void flyTo(JSObject options);
  external void jumpTo(JSObject options);
  external void stop();
  external double getZoom();
  external GlLngLat getCenter();

  /// The drag handler, switched on only where the globe is the reader's to
  /// spin. Toggled here rather than through the widget, so it changes with
  /// the scene and never rebuilds the map.
  external GlHandler get dragPan;

  external JSObject getCanvasContainer();
  external void on(String type, JSFunction listener);
}

extension type GlHandler._(JSObject _) implements JSObject {
  external void enable();
  external void disable();
}

extension type GlLngLat._(JSObject _) implements JSObject {
  external double get lng;
  external double get lat;
}

@JS('maplibregl.Map.prototype')
external JSObject? get _mapPrototype;

/// Finds the GL JS instance the plugin created.
///
/// The plugin keeps it private and GL JS keeps no registry of its maps, so
/// this borrows `triggerRepaint`, a public method every instance calls on
/// itself whenever it has something to draw: the first call reports `this`
/// and puts the original back. [poke] is any plugin call that makes the map
/// repaint. Resolves to null if nothing reported in time, and the caller
/// falls back to the plugin's own camera.
Future<GlMap?> captureGlMap({
  required void Function() poke,
  Duration timeout = const Duration(seconds: 3),
}) {
  final prototype = _mapPrototype;
  if (prototype == null) return Future.value();

  final completer = Completer<GlMap?>();
  final original = prototype.getProperty<JSFunction>('triggerRepaint'.toJS);
  void restore() => prototype.setProperty('triggerRepaint'.toJS, original);

  prototype.setProperty(
    'triggerRepaint'.toJS,
    ((JSObject self) {
      restore();
      if (!completer.isCompleted) completer.complete(self as GlMap);
      return original.callAsFunction(self);
    }).toJSCaptureThis,
  );

  poke();
  return completer.future.timeout(
    timeout,
    onTimeout: () {
      restore();
      return null;
    },
  );
}

/// Where the camera is: a place, a zoom, and how far from the left edge of
/// the canvas the centre of the view is pushed.
///
/// Padding on the left only, because that is the only direction the
/// compositions use: the hero globe pushed right, half out of the frame, and
/// the flat maps nudged right of the fade where the page meets the map.
class Shot {
  const Shot(this.lat, this.lng, this.zoom, {this.padLeft = 0});

  final double lat;
  final double lng;
  final double zoom;
  final double padLeft;

  Shot withZoom(double value) => Shot(lat, lng, value, padLeft: padLeft);

  JSObject options({Duration? duration, double Function(double t)? easing, double? curve}) {
    final padding = JSObject()
      ..setProperty('left'.toJS, padLeft.toJS)
      ..setProperty('right'.toJS, 0.toJS)
      ..setProperty('top'.toJS, 0.toJS)
      ..setProperty('bottom'.toJS, 0.toJS);
    final options = JSObject()
      ..setProperty('center'.toJS, [lng.toJS, lat.toJS].toJS)
      ..setProperty('zoom'.toJS, zoom.toJS)
      // Not marked essential, on purpose: GL JS then honours
      // prefers-reduced-motion by jumping instead of animating, and the page
      // reads the same without the flights.
      ..setProperty('padding'.toJS, padding);
    if (duration != null) options.setProperty('duration'.toJS, duration.inMilliseconds.toJS);
    if (easing != null) {
      options.setProperty('easing'.toJS, ((JSNumber t) => easing(t.toDartDouble).toJS).toJS);
    }
    if (curve != null) options.setProperty('curve'.toJS, curve.toJS);
    return options;
  }
}

/// The easings the transitions are built from.
abstract final class Ease {
  static double inOutCubic(double t) =>
      t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;

  static double inOutSine(double t) => -(math.cos(math.pi * t) - 1) / 2;

  static double outCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();
}
