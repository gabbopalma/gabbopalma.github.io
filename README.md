# Gabriel Palmisano, personal site

A static site in two languages, built with [Jaspr](https://jaspr.site), with one live map in it: a Flutter widget running [maplibre_gl](https://pub.dev/packages/maplibre_gl), the package I maintain.

- `/` is English, `/it/` is Italian. Both are pre-rendered to plain HTML, so the text is readable and indexable before any script runs.
- The map is embedded with `jaspr_flutter_embed` and loaded as a deferred library, after the page is already on screen. It follows the reader: each section of the page is a destination, and the map flies there.
- No API key and no tile provider. The map draws Natural Earth geometry served from the site itself (`web/geo/`), and maplibre-gl-js is served from `web/maplibre/`.

## Where things live

| Path | What |
|---|---|
| `lib/content/` | Every word, number and place on the site. Plain Dart, shared by the page and the map. |
| `lib/content/copy.dart` | All the copy, in English and Italian. |
| `lib/content/talks.dart` | Talks and their stops, from the "Conferenze Palmisano" sheet. The numbers under the talks heading are computed from this list. |
| `lib/components/` | The Jaspr page: one component per section, the top bar, and the map pane. |
| `lib/map/` | The Flutter side: the map widget, its style, a few DOM helpers, and `gl_camera.dart`. |
| `lib/map/gl_camera.dart` | The camera bridge. maplibre_gl's `animateCamera` cannot pass padding or an easing on the web, and every transition here needs both, so camera moves go to the GL JS map directly. The plugin still owns the widget, the style and the layers. If the bridge cannot find the map, the site falls back to the plugin's camera. |
| `web/styles.css` | The stylesheet. Palette and type come from the Berlin deck. |

## Run it

```bash
jaspr serve
```

`jaspr` comes from `dart pub global activate jaspr_cli`.

## Build it

```bash
jaspr build
```

Stop `jaspr serve` first: the two share one build daemon, and the build refuses to start while the dev server holds it with other options.

The output is `build/jaspr/`, a folder of static files that any static host can serve. The build prints `[ERROR] Server process failed unexpectedly` at the very end: that is the pre-rendering server being shut down after it has written both pages, and the output is complete.

The pages use `<base href="/">`, so the site expects to be served from the root of a domain (for example `gabbopalma.github.io`). The absolute URLs for the canonical link, the language alternates and the social preview image use `Links.site` in `lib/content/copy.dart`: change it when the domain changes.

## Deploy

GitHub Pages, from this repository (`gabbopalma.github.io`). `.github/workflows/deploy.yml` builds the site with Flutter 3.47.5 and `jaspr_cli` 0.23.5 on every push to `main`, drops the CanvasKit variants the map does not use, and publishes `build/jaspr`. It can also be run by hand from the Actions tab. There is no scheduled build: the browser reads the live numbers on every visit.

## Live parts

- **Downloads and stars** (`lib/content/package_stats.dart`): read from pub.dev's score API and GitHub's REST API at build time, written into the HTML, then read again in the browser on load. Both APIs allow cross-origin requests. Shown rounded down (130k+, 370+). If a source does not answer, the build falls back to the verified floor and the browser keeps the build's number.
- **Pointing at the map** (desktop with a mouse): every dot says what it is next to the pointer and lights the matching rows, the talk stops in that city or the stop on the About rail. It uses maplibre_gl's `onFeatureHover` on an invisible layer added with `addCircleLayer`. The wheel still scrolls the page over the map. On phones the band stays inert, so a finger on it scrolls the text.

## Updating the content

- A new talk or a new stop: add it to `lib/content/talks.dart`, with the audience from the sheet once the talk has happened. The counters and the "Next stop" line in the hero update by themselves.
- A new city: add it to `Places` in `lib/content/places.dart`. The map pins every place a talk mentions.
- The social preview image is `web/images/og.png`, 1200 × 630.

## Credits

Map data: [Natural Earth](https://www.naturalearthdata.com), public domain. Fonts: Alata, Inter Tight and JetBrains Mono, under the SIL Open Font License (`web/fonts/OFL-*.txt`).
