import 'dart:convert';

import 'package:maplibre_gl/maplibre_gl.dart';

import '../content/places.dart';
import '../content/scene.dart';
import '../content/talks.dart';

/// The site's map style, built here rather than loaded from a provider.
///
/// Natural Earth geometry served from the site's own origin, so there is no
/// API key, no tile provider, and every colour comes from the deck palette
/// instead of fighting it. Same approach as the Berlin deck.
abstract final class MapPalette {
  static const primary = '#285DAA';
  static const accent = '#95BEFA';

  /// The sea of the globe, darker than the flat map's so the sphere reads as
  /// an object sitting on the page.
  static const globeOcean = '#CFDDF3';
  static const flatOcean = '#EAF1FB';

  /// Land on the flat maps: two clear steps away from the sea.
  static const flatLand = '#AFC8EC';
}

/// The feature id of a dot: its group and its place, which together are
/// unique. Promoted from the properties, because GL JS keeps only numeric
/// ids from GeoJSON otherwise, and the hover callback reports this id.
String placeKey(String group, String name) => '$group|$name';

Map<String, Object?> _point(Place place, String group) => {
  'type': 'Feature',
  'geometry': {
    'type': 'Point',
    'coordinates': [place.lng, place.lat],
  },
  'properties': {'key': placeKey(group, place.name), 'name': place.name, 'group': group},
};

List<Map<String, Object?>> _dotLayers(String group) => [
  {
    'id': '$group-halo',
    'type': 'circle',
    'source': 'places',
    'filter': ['==', ['get', 'group'], group],
    'paint': {
      'circle-color': MapPalette.primary,
      'circle-opacity': 0,
      'circle-radius': 20,
    },
  },
  {
    'id': '$group-dot',
    'type': 'circle',
    'source': 'places',
    'filter': ['==', ['get', 'group'], group],
    'paint': {
      'circle-color': MapPalette.primary,
      'circle-radius': 6,
      'circle-stroke-color': '#FFFFFF',
      'circle-stroke-width': 2.5,
      'circle-opacity': 0,
      'circle-stroke-opacity': 0,
    },
  },
];

/// Below this zoom the world map generalisation is drawn, above it the fine
/// one. The globe sits around zoom 2.5, the flat maps above 4.5, so the swap
/// happens mid flight where nobody can see it.
const _detailZoom = 3.4;

final String siteMapStyle = jsonEncode({
  'version': 8,
  'name': 'gabriel-palmisano',
  // Every paint change between scenes animates over this, so the land turns
  // from the globe's blue to the flat map's while the camera is flying.
  'transition': {'duration': 900, 'delay': 0},
  'sources': {
    'land-coarse': {'type': 'geojson', 'data': 'geo/land_110m.json'},
    'land': {'type': 'geojson', 'data': 'geo/land_50m.json'},
    'borders': {'type': 'geojson', 'data': 'geo/borders_50m.json'},
    'route': {
      'type': 'geojson',
      'data': {
        'type': 'Feature',
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            [Places.bari.lng, Places.bari.lat],
            [Places.pesaro.lng, Places.pesaro.lat],
          ],
        },
        'properties': <String, Object?>{},
      },
    },
    'places': {
      'type': 'geojson',
      'promoteId': 'key',
      'data': {
        'type': 'FeatureCollection',
        'features': [
          _point(Places.bari, PlaceGroup.home),
          _point(Places.bari, PlaceGroup.route),
          _point(Places.pesaro, PlaceGroup.route),
          _point(Places.pesaro, PlaceGroup.work),
          for (final place in talkPlaces) _point(place, PlaceGroup.talk),
        ],
      },
    },
  },
  'layers': [
    {
      'id': 'sphere',
      'type': 'background',
      'paint': {'background-color': MapPalette.globeOcean},
    },
    {
      'id': 'land-coarse',
      'type': 'fill',
      'source': 'land-coarse',
      'maxzoom': _detailZoom,
      'paint': {'fill-color': MapPalette.primary},
    },
    {
      'id': 'land',
      'type': 'fill',
      'source': 'land',
      'minzoom': _detailZoom,
      'paint': {'fill-color': MapPalette.primary},
    },
    // The coast at both resolutions, like the land: on a phone the flat maps
    // that frame several cities sit below [_detailZoom].
    {
      'id': 'coast-coarse',
      'type': 'line',
      'source': 'land-coarse',
      'maxzoom': _detailZoom,
      'paint': {
        'line-color': MapPalette.primary,
        'line-width': 1,
        'line-opacity': 0,
      },
    },
    {
      'id': 'coast',
      'type': 'line',
      'source': 'land',
      'minzoom': _detailZoom,
      'paint': {
        'line-color': MapPalette.primary,
        'line-width': 1,
        'line-opacity': 0,
      },
    },
    // Quieter than the coast: at these zooms borders are most of what is on
    // screen, and at full strength they turn Europe into a net. No minzoom:
    // they are invisible on the globe anyway, and a phone's flat maps need
    // them below [_detailZoom].
    {
      'id': 'borders',
      'type': 'line',
      'source': 'borders',
      'paint': {
        'line-color': MapPalette.primary,
        'line-width': 0.8,
        'line-opacity': 0,
      },
    },
    // A soft wide pass under the dashes, so the route reads from a distance
    // without the line itself getting fat.
    {
      'id': 'route-glow',
      'type': 'line',
      'source': 'route',
      'layout': {'line-cap': 'round'},
      'paint': {
        'line-color': MapPalette.primary,
        'line-width': 12,
        'line-blur': 10,
        'line-opacity': 0,
      },
    },
    {
      'id': 'route',
      'type': 'line',
      'source': 'route',
      'paint': {
        'line-color': MapPalette.primary,
        'line-width': 2.5,
        'line-dasharray': [2, 2.2],
        'line-opacity': 0,
      },
    },
    for (final group in PlaceGroup.all) ..._dotLayers(group),
    // The talk stop being pointed at, drawn over the others.
    {
      'id': 'focus-halo',
      'type': 'circle',
      'source': 'places',
      'filter': ['==', ['get', 'name'], ''],
      'paint': {
        'circle-color': MapPalette.primary,
        'circle-opacity': 0,
        'circle-radius': 30,
      },
    },
    // The dot under the pointer. Separate from the focus halo: pointing at
    // the map lights a dot where it is, it never moves the camera away from
    // under the cursor.
    {
      'id': 'hover-halo',
      'type': 'circle',
      'source': 'places',
      'filter': ['==', ['get', 'key'], ''],
      'paint': {
        'circle-color': MapPalette.primary,
        'circle-opacity': 0,
        'circle-radius': 24,
      },
    },
  ],
});

/// The invisible layer the pointer is tested against: larger than a dot, so
/// a dot is easy to hit, and added through the plugin rather than the style
/// because that is what registers it for `onFeatureHover`.
const hitLayerId = 'places-hit';
const hitRadius = 14.0;

/// Any paint or layout values for one layer.
///
/// maplibre_gl ships a typed properties class per layer type, but none for
/// `background`, and the sea changes colour between the globe and the flat
/// maps. On the web the plugin applies each entry with `setPaintProperty`,
/// so a plain map of style spec keys is all this needs to be.
class StyleValues implements LayerProperties {
  const StyleValues(this.values);

  final Map<String, Object?> values;

  @override
  Map<String, dynamic> toJson({bool skipNulls = true}) => values;
}
