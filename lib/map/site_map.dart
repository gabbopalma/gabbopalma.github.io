import 'dart:async';
import 'dart:js_interop';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../content/places.dart';
import '../content/scene.dart';
import '../content/talks.dart';
import 'gl_camera.dart';
import 'map_dom.dart';
import 'site_map_style.dart';

/// The one map on the page. Give it a scene and it goes there.
///
/// The page never touches a controller: it says which section the reader is
/// on and which talk stop they are pointing at, and this widget decides the
/// shot and how to get there. The canvas never changes size. Every
/// composition, including the hero globe half out of the frame, is a camera
/// position plus padding, so a transition is one continuous camera move that
/// can be eased and chained, instead of a resizing canvas racing a flight.
class SiteMap extends StatefulWidget {
  const SiteMap({required this.scene, required this.onPoint, required this.onSpin, super.key});

  final MapScene scene;

  /// The dot under the pointer, or null when the pointer leaves it. The page
  /// labels it and lights the rows that talk about the same place.
  final void Function(PointedPlace? place) onPoint;

  /// The reader has grabbed the open source globe: the page drops its hint.
  final void Function() onSpin;

  @override
  State<SiteMap> createState() => _SiteMapState();
}

class _SiteMapState extends State<SiteMap> with SingleTickerProviderStateMixin {
  /// How long a new section has to stay on screen before the map leaves for
  /// it. Scrolling past three sections makes one flight, not three that each
  /// get cut off.
  static const _settle = Duration(milliseconds: 220);

  /// The same, for pointing from one talk stop to the next.
  static const _settleFocus = Duration(milliseconds: 60);

  /// Tilted north of the equator so the globe shows Europe and Africa, with
  /// Bari on the visible face, instead of a lot of empty ocean.
  static const _heroLat = 30.0;
  static const _heroLng = 15.0;
  static const _openSourceLat = 22.0;

  /// A full turn in two minutes: slow enough to read as drift, not motion.
  static const _driftDegreesPerSecond = 3.0;

  /// Below this zoom the camera is looking at a globe, above it at a map.
  /// GL JS's globe flattens towards mercator as it zooms in; by here the
  /// sphere fills the view and the land can take its flat-map colour.
  static const _globeBelow = 3.6;

  static const _sky = SkyProperties(
    skyColor: 'rgba(255, 255, 255, 0)',
    horizonColor: 'rgba(255, 255, 255, 0)',
    fogColor: 'rgba(255, 255, 255, 0)',
    fogGroundBlend: 0.95,
    horizonFogBlend: 0.35,
    skyHorizonBlend: 0.9,
    atmosphereBlend: 0.25,
  );

  MapLibreMapController? _controller;
  GlMap? _gl;
  bool _ready = false;
  Size _size = Size.zero;
  CameraPosition? _initialCamera;

  /// The last scene the camera was sent to. With [_settle] in between, this
  /// is not always the previous widget's scene.
  MapScene? _shown;
  Timer? _settleTimer;

  /// Bumped whenever a new move replaces one still running, so the later
  /// legs of the old one know they are stale.
  int _generation = 0;
  final List<Timer> _legs = [];

  Ticker? _drift;
  Duration _lastTick = Duration.zero;
  double _driftLng = 0;

  /// Feature ids of the dots under the pointer, see [placeKey].
  final List<String> _under = [];

  /// The beat between letting go of the globe and its trip home.
  Timer? _handBack;

  static bool _isGlobe(Section section) =>
      section == Section.hero || section == Section.openSource;

  @override
  void initState() {
    super.initState();
    // Served from the site itself rather than from unpkg at runtime, by
    // absolute URL: see [siteUrl] for why a relative one breaks.
    MapLibreMap.webLibrarySource = MapLibreJsSource.urls(
      scriptUrl: siteUrl('maplibre/maplibre-gl.mjs'),
      styleUrl: siteUrl('maplibre/maplibre-gl.css'),
    );
  }

  @override
  void didUpdateWidget(SiteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scene == oldWidget.scene) return;

    final sectionChanged = widget.scene.section != oldWidget.scene.section;
    _settleTimer?.cancel();
    _settleTimer = Timer(sectionChanged ? _settle : _settleFocus, () {
      if (mounted) _show(widget.scene);
    });
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _handBack?.cancel();
    _cancelLegs();
    _stopDrift();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Shots: where the camera is for each scene.
  // ---------------------------------------------------------------------

  /// The phone's band across the top, rather than the desktop's right half
  /// whose left edge fades into the page.
  ///
  /// Decided by the same 900 px breakpoint as the stylesheet, not by the
  /// pane's shape: on an ultrawide monitor the desktop half is wider than it
  /// is tall, and reading that as a phone dropped the fade padding and moved
  /// every globe.
  bool get _wide => isBandLayout();

  /// How far right of the canvas centre the flat maps sit, so nothing
  /// important lands under the fade on the desktop.
  double get _flatPad => _wide ? 0 : _size.width * 0.14;

  /// The hero globe: larger than the pane and pushed right, half out of the
  /// frame, as on the title slide in Berlin.
  ///
  /// On the desktop it is sized on the height and placed so that about 38%
  /// of it runs past the right edge, whatever the pane's proportions: on a
  /// tall pane and on an ultrawide one the composition is the same.
  ({double diameter, double padLeft}) get _heroFrame {
    final double side;
    final double centreX;
    if (_wide) {
      side = math.max(_size.height * 1.12, _size.width * 0.95);
      centreX = _size.width * 0.3 + side / 2;
    } else {
      side = _size.height * 1.12;
      centreX = math.max(_size.width / 2, _size.width - side * 0.12);
    }
    // Padding moves the centre of the view to the middle of what is left,
    // so pushing the centre right by d takes 2d of left padding.
    return (diameter: side, padLeft: math.max(0, 2 * centreX - _size.width));
  }

  /// The zoom at which the globe is [diameter] pixels across.
  ///
  /// MapLibre GL JS draws the globe with a radius of
  /// `worldSize / (2 * pi) / cos(latitude)`, where `worldSize` is
  /// `512 * 2^zoom`, so this is that formula solved for the zoom. The
  /// perspective camera makes the sphere look a touch smaller than the
  /// formula says, which is why callers ask for slightly more than they want.
  static double _globeZoom(double diameter, double latitude) {
    final cosLat = math.cos(latitude * math.pi / 180);
    return math.log(diameter * math.pi * cosLat / 512) / math.ln2;
  }

  /// The whole globe in view, centred: the step between a globe and a map.
  double _wholeGlobeZoom(double latitude) =>
      _globeZoom(math.min(_size.width - _flatPad, _size.height) * 0.86, latitude);

  Shot _heroShot({double lngOffset = 0}) {
    final frame = _heroFrame;
    return Shot(
      _heroLat,
      _heroLng + lngOffset,
      _globeZoom(frame.diameter * 0.94, _heroLat),
      padLeft: frame.padLeft,
    );
  }

  Shot _shotFor(MapScene scene) {
    switch (scene.section) {
      case Section.hero:
        return _heroShot();
      case Section.openSource:
        return Shot(
          _openSourceLat,
          _driftLng,
          _globeZoom(math.min(_size.width - _flatPad, _size.height) * 0.8, _openSourceLat),
          padLeft: _flatPad,
        );
      case Section.about:
        return _fit([Places.bari, Places.pesaro]);
      case Section.talks:
        if (scene.focus case final focus?) return _at(focus, 6.2);
        return _fit(talkPlaces);
      case Section.work:
        return _at(Places.pesaro, 6.4);
      case Section.contact:
        return _at(Places.bari, 6.6);
    }
  }

  Shot _at(Place place, double zoom) =>
      Shot(place.lat, place.lng, zoom, padLeft: _flatPad);

  /// Frames a set of places with room around them, computed in Web Mercator.
  ///
  /// Done here rather than with GL JS's `cameraForBounds`, because the shot
  /// also carries padding and the two would count it twice. At the zooms the
  /// flat maps use, GL JS's globe is close enough to mercator that the
  /// difference is a few pixels.
  Shot _fit(List<Place> places) {
    double x(double lng) => (lng + 180) / 360;
    double y(double lat) {
      final r = lat * math.pi / 180;
      return (1 - math.log(math.tan(r) + 1 / math.cos(r)) / math.pi) / 2;
    }

    final lats = places.map((p) => p.lat);
    final lngs = places.map((p) => p.lng);
    final west = lngs.reduce(math.min), east = lngs.reduce(math.max);
    final south = lats.reduce(math.min), north = lats.reduce(math.max);

    final margin = _size.shortestSide * 0.16;
    final width = _size.width - _flatPad - 2 * margin;
    final height = _size.height - 2 * margin;
    final spanX = x(east) - x(west);
    final spanY = y(south) - y(north);
    final zoom = math.log(math.min(width / (spanX * 512), height / (spanY * 512))) / math.ln2;

    final midY = (y(south) + y(north)) / 2;
    final lat = math.atan(_sinh(math.pi * (1 - 2 * midY))) * 180 / math.pi;
    return Shot(lat, (west + east) / 2, math.min(zoom, 7), padLeft: _flatPad);
  }

  static double _sinh(double v) => (math.exp(v) - math.exp(-v)) / 2;

  // ---------------------------------------------------------------------
  // Moves: how the camera gets from one shot to the next.
  // ---------------------------------------------------------------------

  void _show(MapScene scene, {bool animate = true}) {
    if (!_ready) return;
    final gl = _gl;
    if (gl == null) return _fallback(scene);

    final previous = _shown;
    _shown = scene;
    _stopDrift();
    _cancelLegs();
    // A label left over from the last scene would point at a dot that is
    // about to fade out or fly away.
    if (previous?.section != scene.section && _under.isNotEmpty) _clearHover();
    _handBack?.cancel();
    _setGrabbable(scene.section == Section.openSource);
    final generation = ++_generation;
    // Starts from wherever the camera is now, including half way through an
    // earlier move, so an interruption never snaps.
    gl.stop();

    // The open source globe picks up its turn from wherever the camera is
    // facing, so arriving never spins it backwards before it drifts forwards.
    if (scene.section == Section.openSource && previous?.section != Section.openSource) {
      _driftLng = gl.getCenter().lng;
    }

    final to = _shotFor(scene);
    // Decided by the scene the camera was sent to last, not by its zoom: on
    // a phone the flat map that frames every talk city sits below
    // [_globeBelow], and read by zoom it passed for a globe, so pointing at
    // one stop made the whole step back and dive. The zoom only decides
    // before the first move.
    final fromGlobe = previous == null ? gl.getZoom() < _globeBelow : _isGlobe(previous.section);
    final toGlobe = _isGlobe(scene.section);

    void leg(Duration after, void Function() run) {
      _legs.add(Timer(after, () {
        if (mounted && generation == _generation) run();
      }));
    }

    if (!animate) {
      gl.jumpTo(to.options());
      _dress(scene);
      if (scene.section == Section.openSource) _startDrift();
      return;
    }

    if (fromGlobe && !toGlobe) {
      // Globe to map: step back until the whole globe is in view, turning it
      // to face the place on the way, then dive in. The land takes its flat
      // colour during the dive, while the sphere flattens.
      gl.easeTo(
        to.withZoom(_wholeGlobeZoom(to.lat)).options(
          duration: const Duration(milliseconds: 1100),
          easing: Ease.inOutSine,
        ),
      );
      leg(const Duration(milliseconds: 1100), () {
        gl.easeTo(to.options(duration: const Duration(milliseconds: 1700), easing: Ease.inOutCubic));
      });
      leg(const Duration(milliseconds: 1500), () => _dress(scene));
      return;
    }

    if (!fromGlobe && toGlobe) {
      // Map to globe: rise until the map is a whole globe again, then settle
      // into the frame. The land darkens as the sphere comes into view: the
      // rise crosses [_globeBelow] at about 950 ms, and the style's 900 ms
      // fade started at 500 ms is half way there at that moment.
      leg(const Duration(milliseconds: 500), () => _dress(scene, shade: false));
      leg(const Duration(milliseconds: 900), () => shadeGlobe(on: true));
      if (scene.section == Section.hero) {
        // Centred while it rises; pushed right only once it is a globe.
        gl.easeTo(
          Shot(to.lat, to.lng, _wholeGlobeZoom(to.lat), padLeft: _flatPad).options(
            duration: const Duration(milliseconds: 1600),
            easing: Ease.inOutCubic,
          ),
        );
        // Not the shot computed at the start: the hero's own, pushed right.
        leg(const Duration(milliseconds: 1600), () {
          gl.easeTo(_heroShot().options(duration: const Duration(milliseconds: 1100), easing: Ease.inOutCubic));
        });
      } else {
        gl.easeTo(to.options(duration: const Duration(milliseconds: 1900), easing: Ease.inOutCubic));
        leg(const Duration(milliseconds: 2000), _startDrift);
      }
      return;
    }

    if (toGlobe) {
      // Globe to globe: the sphere slides between its two places and changes
      // size in one move.
      _dress(scene);
      gl.easeTo(to.options(duration: const Duration(milliseconds: 1500), easing: Ease.inOutCubic));
      if (scene.section == Section.openSource) {
        leg(const Duration(milliseconds: 1600), _startDrift);
      }
      return;
    }

    // Map to map: GL JS's flyTo is built for this, pulling back just enough
    // to keep both ends in sight. A hop between talk stops is quicker.
    _dress(scene);
    final hop = previous?.section == scene.section;
    gl.flyTo(
      to.options(
        duration: Duration(milliseconds: hop ? 1100 : 1800),
        easing: Ease.inOutCubic,
        curve: 1.3,
      ),
    );
  }

  /// Colours, markers and the globe's shadow for a scene.
  void _dress(MapScene scene, {bool shade = true}) {
    unawaited(_paint(scene));
    if (shade) shadeGlobe(on: _isGlobe(scene.section));
  }

  /// Without the GL JS camera the plugin's own still works: no padding, so
  /// the hero globe is centred instead of half out of the frame, and every
  /// move is GL JS's default flight. Worse, never broken.
  void _fallback(MapScene scene) {
    final controller = _controller;
    if (controller == null) return;
    final to = _shotFor(scene);
    _shown = scene;
    _dress(scene);
    unawaited(
      controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(to.lat, to.lng), zoom: to.zoom)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  void _cancelLegs() {
    for (final timer in _legs) {
      timer.cancel();
    }
    _legs.clear();
  }

  /// Colours and markers for a scene. The style's root transition animates
  /// every change, so the land fades between the globe's blue and the paper
  /// map instead of switching.
  Future<void> _paint(MapScene scene) async {
    final controller = _controller;
    if (controller == null || !_ready) return;

    final section = scene.section;
    final globe = _isGlobe(section);
    final groups = {
      PlaceGroup.home: section == Section.hero || section == Section.contact,
      PlaceGroup.route: section == Section.about,
      PlaceGroup.talk: section == Section.talks,
      PlaceGroup.work: section == Section.work,
    };
    final focus = section == Section.talks ? scene.focus : null;

    final values = <String, Map<String, Object?>>{
      'sphere': {
        'background-color': globe ? MapPalette.globeOcean : MapPalette.flatOcean,
      },
      // Both resolutions: which one is drawn depends on the zoom, not the
      // scene, and a phone's flat maps can sit on the coarse one.
      'land-coarse': {'fill-color': globe ? MapPalette.primary : MapPalette.flatLand},
      'land': {'fill-color': globe ? MapPalette.primary : MapPalette.flatLand},
      'coast-coarse': {'line-opacity': globe ? 0 : 0.7},
      'coast': {'line-opacity': globe ? 0 : 0.7},
      'borders': {'line-opacity': globe ? 0 : 0.3},
      'route': {'line-opacity': section == Section.about ? 0.9 : 0},
      'route-glow': {'line-opacity': section == Section.about ? 0.18 : 0},
      for (final MapEntry(key: group, value: on) in groups.entries) ...{
        '$group-dot': {
          'circle-opacity': on ? 1 : 0,
          'circle-stroke-opacity': on ? 1 : 0,
        },
        '$group-halo': {'circle-opacity': on ? 0.16 : 0},
      },
      'focus-halo': {'circle-opacity': focus == null ? 0 : 0.3},
    };

    await controller.setFilter('focus-halo', [
      'all',
      ['==', ['get', 'group'], PlaceGroup.talk],
      ['==', ['get', 'name'], focus?.name ?? ''],
    ]);
    // Only the dots on screen answer the pointer.
    await controller.setFilter(hitLayerId, ['==', ['get', 'group'], PlaceGroup.visibleIn(section) ?? '']);
    for (final MapEntry(key: layer, value: paint) in values.entries) {
      await controller.setLayerProperties(layer, StyleValues(paint));
    }
  }

  // ---------------------------------------------------------------------
  // The open source globe turns slowly while it is on screen.
  // ---------------------------------------------------------------------

  void _startDrift() {
    _lastTick = Duration.zero;
    _drift ??= createTicker(_onTick)..start();
  }

  void _stopDrift() {
    _drift?.dispose();
    _drift = null;
  }

  void _onTick(Duration elapsed) {
    final seconds = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    _driftLng += _driftDegreesPerSecond * seconds;
    if (_driftLng > 180) _driftLng -= 360;
    // A jump keeps the zoom and padding the shot set, and only turns.
    _gl?.jumpTo(Shot(_openSourceLat, _driftLng, _gl!.getZoom(), padLeft: _flatPad).options());
  }

  // ---------------------------------------------------------------------
  // Lifecycle.
  // ---------------------------------------------------------------------

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    // Hidden until the first shot is composed: see [showMapCanvas].
    showMapCanvas(visible: false);
  }

  Future<void> _onStyleLoaded() async {
    final controller = _controller;
    if (controller == null) return;

    // setProjection repaints the map, which is what lets the capture see it.
    // Web only: on Android and iOS this throws, because MapLibre Native only
    // renders mercator, the exact gap the Berlin talk is about.
    final gl = captureGlMap(poke: () => unawaited(controller.setProjection('globe')));
    await controller.setSky(_sky);
    _gl = await gl;

    // Added through the plugin, not the style, because that is what makes
    // the layer report to onFeatureHover. Transparent: it only catches the
    // pointer, a little wider than the dot it sits under.
    await controller.addCircleLayer(
      'places',
      hitLayerId,
      const CircleLayerProperties(circleRadius: hitRadius, circleColor: '#000000', circleOpacity: 0),
      filter: ['==', ['get', 'group'], ''],
    );
    controller.onFeatureHover.add(_onHover);
    if (_gl case final gl?) {
      // The press, not the drag, takes the globe: the turn moves the camera
      // with jumpTo every frame, and in GL JS a jump stops any gesture in
      // progress, so a turn still running when the drag begins kills it.
      gl.on('mousedown', ((JSAny? _) => _onPress()).toJS);
      gl.on('dragstart', ((JSAny? _) => widget.onSpin()).toJS);
      // Either can come last: a click with no drag ends on mouseup, a drag
      // released outside the map ends on dragend.
      gl.on('mouseup', ((JSAny? _) => _onLetGo()).toJS);
      gl.on('dragend', ((JSAny? _) => _onLetGo()).toJS);
    }

    _ready = true;
    releaseMapCanvasFocus();

    final scene = widget.scene;
    if (_gl case final gl? when scene.section == Section.hero) {
      // The entrance: the globe starts turned away and swings round to Bari.
      _shown = scene;
      _setGrabbable(false);
      gl.jumpTo(_heroShot(lngOffset: -80).options());
      _dress(scene);
      showMapCanvas(visible: true);
      gl.easeTo(_heroShot().options(duration: const Duration(milliseconds: 2600), easing: Ease.outCubic));
    } else {
      // Opened on a link to a section: nobody saw a view to fly from.
      _show(scene, animate: false);
      showMapCanvas(visible: true);
    }
  }

  // ---------------------------------------------------------------------
  // Spinning the open source globe by hand, as on the Berlin title slide.
  // ---------------------------------------------------------------------

  /// How long after letting go the globe starts home: only a beat, so a
  /// second grab right away does not have to race it, and pressing again
  /// cancels the trip anyway.
  static const _handBackDelay = Duration(milliseconds: 400);
  static const _homeFlight = Duration(milliseconds: 1200);

  void _setGrabbable(bool on) {
    final gl = _gl;
    if (gl == null) return;
    on ? gl.dragPan.enable() : gl.dragPan.disable();
    // Explicit 'default' rather than empty: MapLibre's stylesheet gives an
    // interactive map a grab cursor, and only this globe can be grabbed.
    setCanvasCursor(gl.getCanvasContainer(), on ? 'grab' : 'default');
  }

  /// A hand is on the globe: it is theirs from this instant. The turn stops
  /// and anything still in the air is dropped. Outside the open source scene
  /// a press is just a press.
  void _onPress() {
    if (_shown?.section != Section.openSource) return;
    _handBack?.cancel();
    _stopDrift();
    _cancelLegs();
    _generation++;
    if (_gl case final gl?) setCanvasCursor(gl.getCanvasContainer(), 'grabbing');
  }

  /// Let go: a beat later the globe flies back to its frame and turns again.
  ///
  /// It keeps the longitude the drag left it at and restores only what the
  /// composition depends on, the latitude, the zoom and the padding. Flying
  /// back to where it was taken from would be a visible jump backwards,
  /// then a turn through the same ground again.
  void _onLetGo() {
    final gl = _gl;
    if (gl == null || _shown?.section != Section.openSource) return;
    setCanvasCursor(gl.getCanvasContainer(), 'grab');
    _handBack?.cancel();
    final generation = _generation;
    _handBack = Timer(_handBackDelay, () {
      if (!mounted || generation != _generation || _shown?.section != Section.openSource) return;
      _driftLng = gl.getCenter().lng;
      gl.easeTo(_shotFor(_shown!).options(duration: _homeFlight, easing: Ease.inOutCubic));
      _legs.add(Timer(_homeFlight + const Duration(milliseconds: 100), () {
        if (mounted && generation == _generation) _startDrift();
      }));
    });
  }

  // ---------------------------------------------------------------------
  // Pointing at a dot.
  // ---------------------------------------------------------------------

  /// The plugin reports every dot under the pointer on its own: an enter or
  /// a move while it is there, a leave when the pointer goes. The label is
  /// the set of them, so around Urbino it lists every city it covers.
  void _onHover(math.Point<double> point, LatLng _, String id, Annotation? _, HoverEventType type) {
    final before = _under.length;
    if (type == HoverEventType.leave) {
      _under.remove(id);
    } else if (!_under.contains(id)) {
      _under.add(id);
    }
    if (_under.isEmpty) return _clearHover();
    if (_under.length != before) unawaited(_lightHover(_under));

    widget.onPoint(
      PointedPlace(
        group: _under.first.split('|').first,
        names: [for (final key in _under) key.split('|').last],
        x: point.x / _size.width,
        y: point.y / _size.height,
      ),
    );
  }

  void _clearHover() {
    _under.clear();
    unawaited(_lightHover(const []));
    widget.onPoint(null);
  }

  Future<void> _lightHover(List<String> keys) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.setFilter('hover-halo', [
      'in',
      ['get', 'key'],
      ['literal', keys],
    ]);
    await controller.setLayerProperties('hover-halo', StyleValues({'circle-opacity': keys.isEmpty ? 0 : 0.28}));
  }

  /// The window changed size: put the camera back on its composition.
  void _onResize() {
    if (!_ready || _gl == null) return;
    final scene = _shown ?? widget.scene;
    _gl!.jumpTo(_shotFor(scene).options());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          if (size != _size) {
            final hadSize = _size != Size.zero;
            _size = size;
            if (hadSize) {
              SchedulerBinding.instance.addPostFrameCallback((_) => _onResize());
            }
          }
          // Only read once: the map takes its first camera from here, and
          // the entrance replaces it as soon as the camera is reachable.
          _initialCamera ??= CameraPosition(
            target: const LatLng(_heroLat, _heroLng - 80),
            zoom: _heroShot().zoom,
          );

          return MapLibreMap(
            styleString: siteMapStyle,
            initialCameraPosition: _initialCamera!,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            compassEnabled: false,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            tiltGesturesEnabled: false,
            dragEnabled: false,
            doubleClickZoomEnabled: false,
          );
        },
      ),
    );
  }
}
