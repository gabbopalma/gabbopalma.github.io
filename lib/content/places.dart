import 'dart:math' as math;

import 'lang.dart';

/// A point on the earth the map can fly to.
///
/// Plain Dart on purpose: the page builds it on the server during
/// pre-rendering, and the Flutter map receives the same object on the client.
class Place {
  const Place(this.name, this.lat, this.lng, {this.nameIt});

  /// Also the feature id on the map, so a place and its dot cannot disagree.
  final String name;
  final double lat;
  final double lng;

  /// Only where the Italian name differs: Milano, Berlino.
  final String? nameIt;

  String label(Lang lang) => lang == Lang.it ? nameIt ?? name : name;

  /// Great circle distance in kilometres, computed rather than written down
  /// so a label can never drift away from the coordinate the camera visits.
  double distanceKmTo(Place other) {
    const earthRadiusKm = 6371.0088;
    double radians(double degrees) => degrees * math.pi / 180;

    final dLat = radians(other.lat - lat);
    final dLng = radians(other.lng - lng);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(radians(lat)) *
            math.cos(radians(other.lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  @override
  bool operator ==(Object other) => other is Place && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

/// Every place the site names. City centres, because that is the honest
/// precision for "I spoke there" and nothing zooms close enough to want more.
abstract final class Places {
  static const bari = Place('Bari', 41.1171, 16.8719);
  static const pesaro = Place('Pesaro', 43.9102, 12.9132);
  static const berlin = Place('Berlin', 52.5003, 13.2707, nameIt: 'Berlino');
  static const vicenza = Place('Vicenza', 45.5455, 11.5354);
  static const campobasso = Place('Campobasso', 41.5603, 14.6627);
  static const milan = Place('Milan', 45.4642, 9.1900, nameIt: 'Milano');
  static const lecce = Place('Lecce', 40.3515, 18.1750);
  static const mestre = Place('Mestre', 45.4903, 12.2425);
  static const urbino = Place('Urbino', 43.7262, 12.6366);
  static const urbania = Place('Urbania', 43.6680, 12.5226);
  static const cagli = Place('Cagli', 43.5466, 12.6481);
}
