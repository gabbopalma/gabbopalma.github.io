import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

import '../content/scene.dart';

// The map is a Flutter widget, so it is imported on the web only (the
// pre-rendering server cannot compile Flutter) and as a deferred library,
// so the text of the page is readable before Flutter has even started.
@Import.onWeb('../map/site_map.dart', show: [#SiteMap])
import 'map_pane.imports.dart' deferred as map;

/// What a dot on the map is, shown next to the pointer: a place, then one
/// entry per thing that happened there, each a main line and the smaller
/// lines under it (a talk, then every time it was given there).
class MapTip {
  const MapTip({required this.at, required this.title, required this.entries});

  final PointedPlace at;
  final String title;
  final List<(String main, List<String> subs)> entries;
}

/// The fixed pane the map lives in: the right half on a desktop, a band at
/// the top on a phone. The stylesheet decides which.
class MapPane extends StatelessComponent {
  const MapPane({
    required this.scene,
    required this.caption,
    required this.onPoint,
    required this.onSpin,
    this.tip,
    this.hint,
    this.clear,
    super.key,
  });

  /// When a talk stop is selected: the label and the action of the cross in
  /// the caption that lets it go.
  final (String, void Function())? clear;

  final MapScene scene;
  final String caption;
  final void Function(PointedPlace? place) onPoint;
  final void Function() onSpin;
  final MapTip? tip;

  /// "Drag to spin the globe", under the open source globe until the first
  /// drag. The stylesheet shows it only where there is a mouse to drag with.
  final String? hint;

  /// A plain pointer arrow, tip at the origin. Filled in MapLibre blue and
  /// outlined in white by the stylesheet, so it reads on the globe's sea
  /// and on its land.
  static const _arrowPath = 'M1 1 L1 17 L5.5 12.8 L8.6 20 L11.4 18.8 L8.3 11.7 L14.2 11.7 Z';

  @override
  Component build(BuildContext context) {
    // Not aria-hidden: the map takes focus and the pointer now (dots answer
    // a hover, the open source globe can be dragged), and hiding a focused
    // element from assistive technology is what Chrome rightly warns about.
    return div(classes: 'map-pane', [
      FlutterEmbedView.deferred(
        classes: 'map-view',
        // Shown until Flutter draws its first frame: the outline of the
        // globe, in the same place, so the live map takes over from it.
        loader: div(classes: 'map-loader', [div(classes: 'map-loader-globe', [])]),
        loadLibrary: map.loadLibrary(),
        builder: () => map.SiteMap(scene: scene, onPoint: onPoint, onSpin: onSpin),
      ),
      div(classes: 'map-fade', []),
      // The hint is a cursor with a name tag, like the ones that show where
      // Claude is pointing: it glides up to the globe, presses, drags a
      // little, lets go, and says what it is doing.
      if (hint case final hint?)
        div(classes: 'map-cursor', [
          svg(
            viewBox: '0 0 16 22',
            width: 18.px,
            height: 24.px,
            classes: 'cursor-arrow',
            attributes: {'aria-hidden': 'true'},
            [path(d: _arrowPath, [])],
          ),
          span(classes: 'cursor-label', [.text(hint)]),
        ]),
      if (tip case final tip?)
        div(
          // Towards the right edge the label opens to the left of the
          // pointer, so it never runs off the screen.
          classes: tip.at.x > 0.62 ? 'map-tip flip' : 'map-tip',
          // Fractions of the map, so the label lands on the pointer
          // whatever pixel size the map itself is drawn at.
          attributes: {
            'style': 'left: ${(tip.at.x * 100).toStringAsFixed(2)}%; top: ${(tip.at.y * 100).toStringAsFixed(2)}%',
          },
          [
            span(classes: 'tip-title', [.text(tip.title)]),
            for (final (main, subs) in tip.entries)
              span(classes: 'tip-entry', [
                span(classes: 'tip-main', [.text(main)]),
                for (final sub in subs) span(classes: 'tip-sub', [.text(sub)]),
              ]),
          ],
        ),
      p(classes: clear == null ? 'map-caption' : 'map-caption with-clear', [
        .text(caption),
        // The visible way out of a selected talk stop, on a phone the
        // obvious one: the caption names the stop, the cross lets it go.
        if (clear case (final label, final onPressed))
          button(
            classes: 'caption-clear',
            attributes: {'type': 'button', 'aria-label': label, 'title': label},
            onClick: onPressed,
            [.text('×')],
          ),
      ]),
    ]);
  }
}
