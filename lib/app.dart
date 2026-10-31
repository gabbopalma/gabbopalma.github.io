import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/site_page.dart';
import 'content/copy.dart';
import 'content/lang.dart';
import 'content/package_stats.dart';
import 'content/talks.dart';

/// The static pages, each with its own head: the site in each language, and
/// a page per deck of slides.
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
        for (final lang in Lang.values) ...[
          Route(path: _route(lang.path), title: Meta.title[lang], builder: (context, state) => _page(lang)),
          // A deck's own page is the site with that talk's slides open on it,
          // so a link goes straight to the slides and its preview shows them.
          for (final talk in talks)
            if (talk.deck case final deck?)
              Route(
                path: _route(deck.path(lang)),
                title: _deckTitle(talk, lang),
                builder: (context, state) => _page(lang, talk: talk),
              ),
        ],
      ],
    );
  }

  /// Routes are written without the trailing slash; the page is built as
  /// `index.html` in that folder all the same.
  static String _route(String path) => path == '/' ? '/' : path.replaceAll(RegExp(r'/$'), '');

  static String _deckTitle(Talk talk, Lang lang) =>
      '${talk.short[lang]} · ${TalksCopy.slidesTitle[lang]} · Gabriel Palmisano';

  Component _page(Lang lang, {Talk? talk}) {
    final deck = talk?.deck;
    String pathIn(Lang which) => deck?.path(which) ?? which.path;
    final url = '${Links.site}${pathIn(lang)}';
    final title = talk == null ? Meta.title[lang] : _deckTitle(talk, lang);
    final description = talk?.summary[lang] ?? Meta.description[lang];

    return Component.fragment([
      // A deck's page is drawn with the slides already open, so the page
      // behind them starts out still.
      Document.html(attributes: {'lang': lang.code, if (deck != null) 'class': 'viewer-open'}),
      Document.head(
        title: title,
        meta: {'description': description},
        children: [
          link(rel: 'canonical', href: url),
          for (final other in Lang.values)
            link(
              rel: 'alternate',
              href: '${Links.site}${pathIn(other)}',
              attributes: {'hreflang': other.code},
            ),
          link(rel: 'alternate', href: '${Links.site}${pathIn(Lang.en)}', attributes: {'hreflang': 'x-default'}),
          _property('og:type', 'website'),
          _property('og:url', url),
          _property('og:title', title),
          _property('og:description', description),
          _property('og:image', deck == null ? '${Links.site}/images/og.png' : '${Links.site}/${deck.share}'),
          _property('og:locale', lang == Lang.en ? 'en_US' : 'it_IT'),
          meta(name: 'twitter:card', content: 'summary_large_image'),
          script(attributes: {'type': 'application/ld+json'}, content: _structuredData(lang)),
        ],
      ),
      SitePage(langCode: lang.code, downloads: stats.monthlyDownloads, stars: stats.stars, deck: deck?.id),
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
