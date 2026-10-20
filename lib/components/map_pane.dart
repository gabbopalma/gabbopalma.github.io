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
    this.tip,
    super.key,
  });

  final MapScene scene;
  final String caption;
  final void Function(PointedPlace? place) onPoint;
  final MapTip? tip;

  @override
  Component build(BuildContext context) {
    return div(classes: 'map-pane', attributes: {'aria-hidden': 'true'}, [
      FlutterEmbedView.deferred(
        classes: 'map-view',
        // Shown until Flutter draws its first frame: the outline of the
        // globe, in the same place, so the live map takes over from it.
        loader: div(classes: 'map-loader', [div(classes: 'map-loader-globe', [])]),
        loadLibrary: map.loadLibrary(),
        builder: () => map.SiteMap(scene: scene, onPoint: onPoint),
      ),
      div(classes: 'map-fade', []),
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
      p(classes: 'map-caption', [.text(caption)]),
    ]);
  }
}
