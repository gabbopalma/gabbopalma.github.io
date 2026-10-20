/// The entrypoint for the **server** environment.
///
/// Runs only at build time: `jaspr build` starts it, renders each route to a
/// static HTML file, and stops it. The site itself has no server.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'app.dart';
import 'content/package_stats.dart';
import 'main.server.options.dart';

Future<void> main() async {
  Jaspr.initializeApp(options: defaultServerOptions);

  // Read once per build and written into both pages. The browser asks again
  // on load, so a stale build only shows yesterday's numbers until then.
  final stats = await PackageStats.fetch();
  final buildStamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);

  runApp(
    Document(
      title: 'Gabriel Palmisano',
      lang: 'en',
      meta: {
        'theme-color': '#F7F9FC',
        'author': 'Gabriel Palmisano',
      },
      head: [
        // The fonts are declared at the top of this small stylesheet, so the
        // browser finds them early without a preload. Preloading them made
        // Chrome warn that they were "not used within a few seconds".
        // Versioned by build, so a new deploy never shows a cached stylesheet
        // from the previous one next to the new markup.
        link(rel: 'stylesheet', href: 'styles.css?v=$buildStamp'),
        link(rel: 'icon', href: 'favicon.png', type: 'image/png'),
        link(rel: 'apple-touch-icon', href: 'apple-touch-icon.png'),
        // Flutter's loader. The map's engine starts from here, after the
        // page's own text is already on screen.
        script(src: 'flutter_bootstrap.js', async: true),
      ],
      body: App(stats: stats),
    ),
  );
}
