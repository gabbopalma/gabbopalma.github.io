import 'places.dart';

/// Which part of the page the reader is on. Each one is also a map scene.
enum Section {
  hero('top'),
  about('about'),
  openSource('open-source'),
  talks('talks'),
  work('work'),
  contact('contact');

  const Section(this.anchor);

  /// The element id, and so the `#fragment` a link scrolls to.
  final String anchor;
}

/// The groups of dots on the map. One place can be in more than one group:
/// Pesaro is a stop on the route, a talk city and the office.
abstract final class PlaceGroup {
  static const home = 'home';
  static const route = 'route';
  static const talk = 'talk';
  static const work = 'work';

  static const all = [home, route, talk, work];

  /// The one group whose dots are on screen in [section], if any.
  static String? visibleIn(Section section) => switch (section) {
    Section.hero || Section.contact => home,
    Section.about => route,
    Section.talks => talk,
    Section.work => work,
    Section.openSource => null,
  };
}

/// The dots on the map the reader is pointing at, and where the pointer is,
/// as a fraction of the map's width and height so the page can place a label
/// there whatever the map's own pixel size is.
class PointedPlace {
  const PointedPlace({required this.group, required this.names, required this.x, required this.y});

  final String group;

  /// [Place.name] of every dot under the pointer, in the order the pointer
  /// reached them. Usually one; around Urbino, at the zoom that frames every
  /// talk, four cities overlap.
  final List<String> names;
  final double x;
  final double y;
}

/// What the map shows: the section the reader is on, plus the one place
/// they are pointing at, if any.
///
/// The page describes a destination and never touches a map controller. The
/// Flutter side decides how to get there.
class MapScene {
  const MapScene(this.section, {this.focus});

  final Section section;
  final Place? focus;

  @override
  bool operator ==(Object other) =>
      other is MapScene && other.section == section && other.focus == focus;

  @override
  int get hashCode => Object.hash(section, focus);
}
