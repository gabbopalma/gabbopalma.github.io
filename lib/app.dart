import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/site_page.dart';
import 'content/copy.dart';
import 'content/lang.dart';
import 'content/package_stats.dart';

/// Two static pages, one per language, each with its own head.
///
/// With multi-page routing this runs only on the server during pre-rendering.
/// The browser mounts [SitePage] on its own.
class App extends StatelessComponent {
  const App({required this.stats, super.key});

  /// Downloads and stars as they were at build time.
  final PackageStats stats;

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        for (final lang in Lang.values)
          Route(
            path: lang.path == '/' ? '/' : lang.path.replaceAll(RegExp(r'/$'), ''),
            title: Meta.title[lang],
            builder: (context, state) => _page(lang),
          ),
      ],
    );
  }

  Component _page(Lang lang) {
    final url = '${Links.site}${lang.path}';
    return Component.fragment([
      Document.html(attributes: {'lang': lang.code}),
      Document.head(
        title: Meta.title[lang],
        meta: {'description': Meta.description[lang]},
        children: [
          link(rel: 'canonical', href: url),
          for (final other in Lang.values)
            link(
              rel: 'alternate',
              href: '${Links.site}${other.path}',
              attributes: {'hreflang': other.code},
            ),
          link(rel: 'alternate', href: '${Links.site}/', attributes: {'hreflang': 'x-default'}),
          _property('og:type', 'website'),
          _property('og:url', url),
          _property('og:title', Meta.title[lang]),
          _property('og:description', Meta.description[lang]),
          _property('og:image', '${Links.site}/images/og.png'),
          _property('og:locale', lang == Lang.en ? 'en_US' : 'it_IT'),
          meta(name: 'twitter:card', content: 'summary_large_image'),
          script(attributes: {'type': 'application/ld+json'}, content: _structuredData(lang)),
        ],
      ),
      SitePage(langCode: lang.code, downloads: stats.monthlyDownloads, stars: stats.stars),
    ]);
  }

  /// Who the site is about, in the schema.org shape search engines read:
  /// the same facts as the page, and the profiles that are the same person,
  /// so a search for the name can tie them to the site.
  static String _structuredData(Lang lang) {
    final person = '${Links.site}/#person';
    final json = jsonEncode({
      '@context': 'https://schema.org',
      '@graph': [
        {
          '@type': 'WebSite',
          '@id': '${Links.site}/#website',
          'url': '${Links.site}/',
          'name': 'Gabriel Palmisano',
          'publisher': {'@id': person},
        },
        {
          '@type': 'Person',
          '@id': person,
          'name': 'Gabriel Palmisano',
          'url': '${Links.site}/',
          'image': '${Links.site}/images/gabriel-stage.jpg',
          'description': Meta.description[lang],
          'jobTitle': WorkCopy.jobs.first.role[lang],
          'worksFor': {'@type': 'Organization', 'name': 'EBWorld', 'url': Links.ebworld},
          'homeLocation': {
            '@type': 'Place',
            'address': {'@type': 'PostalAddress', 'addressLocality': 'Bari', 'addressCountry': 'IT'},
          },
          'knowsAbout': ['Flutter', 'Dart', 'MapLibre', 'maplibre_gl'],
          'sameAs': [Links.github, Links.linkedin, Links.sessionize, Links.x, Links.instagram],
        },
      ],
    });
    // Inside a script element, "</" could close it early.
    return json.replaceAll('</', r'<\/');
  }

  static Component _property(String property, String content) =>
      meta(attributes: {'property': property}, content: content);
}
