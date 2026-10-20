import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'lang.dart';

/// The two numbers in the open source section that change on their own:
/// downloads on pub.dev and stars on GitHub.
///
/// Read twice. At build time the pre-rendering server fetches them and
/// writes them into the HTML, so the page has numbers before any script
/// runs. In the browser the page asks again and updates them if they moved.
/// Both APIs answer with `Access-Control-Allow-Origin: *`, and GitHub's
/// unauthenticated limit (60 requests an hour per visitor) is far more than
/// one page load needs.
class PackageStats {
  const PackageStats({required this.monthlyDownloads, required this.stars});

  /// The verified floor from cv-tailor's facts (October 2026), used when a
  /// source does not answer.
  static const fallback = PackageStats(monthlyDownloads: 125000, stars: 300);

  /// `downloadCount30Days` from pub.dev's score API.
  final int monthlyDownloads;

  /// `stargazers_count` of the repository.
  final int stars;

  static final _pubDev = Uri.parse('https://pub.dev/api/packages/maplibre_gl/score');
  static final _github = Uri.parse('https://api.github.com/repos/maplibre/flutter-maplibre-gl');

  /// Fetches both, keeping [orElse]'s value for any source that fails.
  static Future<PackageStats> fetch({PackageStats orElse = fallback}) async {
    final [downloads, stars] = await Future.wait([
      _readInt(_pubDev, 'downloadCount30Days'),
      _readInt(_github, 'stargazers_count'),
    ]);
    return PackageStats(
      monthlyDownloads: downloads ?? orElse.monthlyDownloads,
      stars: stars ?? orElse.stars,
    );
  }

  static Future<int?> _readInt(Uri url, String key) async {
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final value = (jsonDecode(response.body) as Map<String, Object?>)[key];
      return value is int && value > 0 ? value : null;
    } on Object {
      return null;
    }
  }
}

/// Rounded down, never up: "130k+" for 131,021. A number on the page should
/// survive someone checking it the same day.
String approxDownloads(int value, Lang lang) {
  if (value >= 1000000) {
    final millions = (value ~/ 100000) / 10;
    final text = millions == millions.roundToDouble()
        ? millions.toStringAsFixed(0)
        : millions.toStringAsFixed(1);
    return '${lang == Lang.it ? text.replaceAll('.', ',') : text}M+';
  }
  if (value >= 10000) return '${value ~/ 5000 * 5}k+';
  return '${value ~/ 1000}k+';
}

/// "370+" for 374; to the hundred above a thousand.
String approxStars(int value, Lang lang) {
  if (value >= 1000) {
    final thousands = (value ~/ 100) / 10;
    final text = thousands.toStringAsFixed(1);
    return '${lang == Lang.it ? text.replaceAll('.', ',') : text}k+';
  }
  return '${value ~/ 10 * 10}+';
}
