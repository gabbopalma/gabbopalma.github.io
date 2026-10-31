import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../content/copy.dart';
import '../content/lang.dart';
import '../content/package_stats.dart';
import '../content/places.dart';
import '../content/scene.dart';
import '../content/talks.dart';
import 'map_pane.dart';
import 'sections/about_section.dart';
import 'sections/contact_section.dart';
import 'sections/hero_section.dart';
import 'sections/open_source_section.dart';
import 'sections/talks_section.dart';
import 'sections/work_section.dart';
import 'slide_viewer.dart';
import 'top_bar.dart';

/// The whole page, in one language.
///
/// Pre-rendered to HTML at build time, so the text is there before any
/// script runs, then brought to life on the client: it watches the scroll to
/// know which section the reader is on, and hands that to the map.
@client
class SitePage extends StatefulComponent {
  const SitePage({required this.langCode, required this.downloads, required this.stars, this.deck, super.key});

  /// A string rather than a [Lang], because a client component's parameters
  /// travel from the server to the browser inside the HTML.
  final String langCode;

  /// The package numbers as the build read them. See [PackageStats].
  final int downloads;
  final int stars;

  /// On a deck's own page, the [Deck.id] of the slides it opens on.
  final String? deck;

  @override
  State<SitePage> createState() => SitePageState();
}

class SitePageState extends State<SitePage> {
  Section _section = Section.hero;
  Stop? _focused;

  /// The dot on the map under the pointer, if any.
  PointedPlace? _pointed;

  /// The reader has spun the open source globe once: the hint has done its
  /// job and does not come back.
  bool _spun = false;

  late PackageStats _stats = PackageStats(monthlyDownloads: component.downloads, stars: component.stars);

  /// The talk whose slides are open, and the slide in view.
  Talk? _deck;
  int _slide = 0;

  /// The slide in view at twice its size, by the mouse or the keys.
  bool _zoomed = false;

  /// The browser's own zoom is in, from a pinch on a phone.
  bool _pinched = false;

  /// The slides were opened from the page, with a history entry of their
  /// own, so the back button closes them. A deck's own page opens with none:
  /// there, back leaves.
  bool _pushed = false;

  JSFunction? _onScroll;
  JSFunction? _onClickAnywhere;
  JSFunction? _onKey;
  JSFunction? _onBack;
  JSFunction? _onPinch;
  bool _frameRequested = false;

  Lang get _lang => Lang.fromCode(component.langCode);

  @override
  void initState() {
    super.initState();

    // A deck's own page opens on its slides from the first render, so the
    // viewer is in the HTML before any script runs.
    if (component.deck case final id?) _deck = talks.where((talk) => talk.deck?.id == id).firstOrNull;

    if (!kIsWeb) return;

    if (_deck != null) {
      // "#7" in the address is the seventh slide.
      final asked = int.tryParse(web.window.location.hash.replaceFirst('#', ''));
      web.window.requestAnimationFrame(
        ((JSNumber _) {
          // Only now, after hydration: it sets the page's attributes back to
          // the pre-rendered ones, and inert is not among them.
          _shutOut(true);
          (web.document.querySelector('.viewer') as web.HTMLElement?)?.focus();
          if (asked != null && asked > 1) SlideViewer.go(asked - 1, instant: true);
        }).toJS,
      );
    }

    _onBack = ((web.Event _) {
      if (_deck == null || !_pushed) return;
      _pushed = false;
      _closeDeck(fromHistory: true);
    }).toJS;
    web.window.addEventListener('popstate', _onBack);

    // A pinch zooms the visual viewport; while it is in, the slides hold
    // still, so a finger moves around the slide instead of turning it.
    _onPinch = ((web.Event _) {
      final pinched = (web.window.visualViewport?.scale ?? 1) > 1.01;
      if (pinched != _pinched) setState(() => _pinched = pinched);
    }).toJS;
    web.window.visualViewport?.addEventListener('resize', _onPinch);

    _onScroll = ((web.Event _) => _scheduleDetect()).toJS;
    web.window.addEventListener('scroll', _onScroll, web.AddEventListenerOptions(passive: true));
    web.window.addEventListener('resize', _onScroll);
    _scheduleDetect();

    // Letting go of a selected stop: a tap or a click anywhere that is not
    // a stop (the stop itself toggles), or Escape.
    _onClickAnywhere = ((web.Event event) {
      if (_focused == null) return;
      final target = event.target;
      if (target != null && target.isA<web.Element>() && (target as web.Element).closest('.stops .stop') != null) {
        return;
      }
      _focus(null);
    }).toJS;
    _onKey = ((web.KeyboardEvent event) {
      if (_deck != null) {
        _onViewerKey(event);
        return;
      }
      if (event.key != 'Escape') return;
      _focus(null);
      // A stop that still holds focus would keep its ring after letting go.
      final active = web.document.activeElement;
      if (active != null && active.closest('.stops .stop') != null) (active as web.HTMLElement).blur();
    }).toJS;
    web.document.addEventListener('click', _onClickAnywhere);
    web.document.addEventListener('keydown', _onKey);

    // Ask again from the browser: the build may be days old. Keeps the
    // build's numbers for any source that does not answer.
    unawaited(
      PackageStats.fetch(orElse: _stats).then((fresh) {
        if (!mounted) return;
        if (fresh.monthlyDownloads == _stats.monthlyDownloads && fresh.stars == _stats.stars) return;
        setState(() => _stats = fresh);
      }),
    );
  }

  @override
  void dispose() {
    if (_onScroll case final listener?) {
      web.window.removeEventListener('scroll', listener);
      web.window.removeEventListener('resize', listener);
    }
    if (_onClickAnywhere case final listener?) web.document.removeEventListener('click', listener);
    if (_onKey case final listener?) web.document.removeEventListener('keydown', listener);
    if (_onBack case final listener?) web.window.removeEventListener('popstate', listener);
    if (_onPinch case final listener?) web.window.visualViewport?.removeEventListener('resize', listener);
    super.dispose();
  }

  /// At most one check per frame, however fast the scroll events arrive.
  void _scheduleDetect() {
    if (_frameRequested) return;
    _frameRequested = true;
    web.window.requestAnimationFrame(
      ((JSNumber _) {
        _frameRequested = false;
        _detect();
      }).toJS,
    );
  }

  /// The current section is the last one whose top has crossed the middle of
  /// the screen. At the very bottom of the page it is the last section, even
  /// when that one is too short to reach the middle.
  void _detect() {
    final threshold = web.window.innerHeight * 0.5;
    var current = Section.hero;
    for (final section in Section.values) {
      final element = web.document.getElementById(section.anchor);
      if (element != null && element.getBoundingClientRect().top <= threshold) {
        current = section;
      }
    }
    final scrolled = web.window.innerHeight + web.window.scrollY;
    if (scrolled >= web.document.documentElement!.scrollHeight - 4) {
      current = Section.values.last;
    }

    if (current != _section) {
      setState(() {
        _section = current;
        if (current != Section.talks) _focused = null;
        _pointed = null;
      });
    }
  }

  void _focus(Stop? stop) {
    if (identical(stop, _focused)) return;
    setState(() => _focused = stop);
  }

  void _openDeck(Talk talk) {
    SlideViewer.reset();
    setState(() {
      _deck = talk;
      _slide = 0;
    });
    _shutOut(true);
    // The slides get an address of their own and a step in the history, so
    // the address can be shared and the back button closes them.
    if (talk.deck case final deck?) {
      web.window.history.pushState(null, '', deck.path(_lang));
      _pushed = true;
    }
    // Once the viewer is on the page it takes the focus, so the keys and a
    // screen reader start from it.
    web.window.requestAnimationFrame(
      ((JSNumber _) => (web.document.querySelector('.viewer') as web.HTMLElement?)?.focus()).toJS,
    );
  }

  /// The address follows the slide in view: "#7" for the seventh, nothing
  /// for the first, so the address bar always links to what is on screen.
  void _turnTo(int page) {
    setState(() {
      _slide = page;
      _zoomed = false;
    });
    if (_deck?.deck case final deck?) {
      web.window.history.replaceState(null, '', '${deck.path(_lang)}${page > 0 ? '#${page + 1}' : ''}');
    }
  }

  /// Closes the slides. Opened from the page, they take their history step
  /// away with them, unless the back button already has. On a deck's own
  /// page there is no step to go back to: the address becomes the site's,
  /// at its talks, and the page scrolls there.
  void _closeDeck({bool fromHistory = false}) {
    final id = _deck?.deck?.id;
    setState(() {
      _deck = null;
      _zoomed = false;
    });
    _shutOut(false);
    var landed = false;
    if (_pushed) {
      _pushed = false;
      web.window.history.back();
    } else if (!fromHistory) {
      web.window.history.replaceState(null, '', '${_lang.path}#${Section.talks.anchor}');
      landed = true;
    }
    // Back to the cover of the deck.
    if (id == null) return;
    final cover = web.document.querySelector('.deck-open[data-deck="$id"]') as web.HTMLElement?;
    if (landed) cover?.scrollIntoView(web.ScrollIntoViewOptions(block: 'center', behavior: 'instant'));
    cover?.focus(web.FocusOptions(preventScroll: true));
  }

  /// While the viewer is open, the page behind it neither scrolls nor takes
  /// the focus.
  void _shutOut(bool shut) {
    web.document.documentElement!.classList.toggle('viewer-open', shut);
    for (final selector in const ['.topbar', 'main.content', '.map-pane']) {
      (web.document.querySelector(selector) as web.HTMLElement?)?.inert = shut;
    }
  }

  /// Arrows and page keys turn the slides, Home and End jump to either end,
  /// + and - zoom, Escape lets go of the zoom first, then closes.
  void _onViewerKey(web.KeyboardEvent event) {
    if (event.key == 'Escape') {
      if (_zoomed) {
        setState(() => _zoomed = false);
      } else {
        _closeDeck();
      }
      return;
    }
    if (event.key == '+' || event.key == '=') {
      if (!_zoomed) {
        setState(() => _zoomed = true);
        SlideViewer.centerSoon((0.5, 0.5));
      }
      return;
    }
    if (event.key == '-') {
      if (_zoomed) setState(() => _zoomed = false);
      return;
    }
    final void Function()? turn = switch (event.key) {
      'ArrowRight' || 'PageDown' => () => SlideViewer.step(1, _slide),
      'ArrowLeft' || 'PageUp' => () => SlideViewer.step(-1, _slide),
      'Home' => () => SlideViewer.go(0),
      'End' => () => SlideViewer.go((_deck?.deck?.pages ?? 1) - 1),
      _ => null,
    };
    if (turn == null) return;
    event.preventDefault();
    turn();
  }

  void _spin() {
    if (_spun) return;
    setState(() => _spun = true);
  }

  void _point(PointedPlace? place) {
    if (place == null && _pointed == null) return;
    setState(() => _pointed = place);
  }

  /// What the dots under the pointer are, in words.
  MapTip? _tip(Lang lang) {
    final at = _pointed;
    if (at == null) return null;

    if (at.group == PlaceGroup.talk) {
      final here = [
        for (final (talk, stop) in allStops)
          if (at.names.contains(stop.place.name)) (talk, stop),
      ];
      if (here.isEmpty) return null;
      final cities = [for (final name in at.names) here.firstWhere((e) => e.$2.place.name == name).$2.place];
      final several = cities.length > 1;

      // One entry per talk, its stops under it in date order: Eco+Eco once
      // with five dates, not five times.
      final byTalk = <Talk, List<String>>{};
      for (final (talk, stop) in here) {
        (byTalk[talk] ??= []).add(
          [formatDate(stop.date, lang), stop.event[lang], if (several) stop.place.label(lang)].join(' · '),
        );
      }
      return MapTip(
        at: at,
        title: cities.map((place) => place.label(lang)).join(', '),
        entries: [for (final MapEntry(key: talk, value: subs) in byTalk.entries) (talk.short[lang], subs)],
      );
    }

    // Home, the route and the office are Bari and Pesaro.
    return MapTip(
      at: at,
      title: at.names.map((name) => name == Places.pesaro.name ? Places.pesaro.label(lang) : Places.bari.label(lang)).join(', '),
      entries: [
        for (final name in at.names) ((name == Places.pesaro.name ? AboutCopy.pesaro : AboutCopy.bari)[lang], const <String>[]),
      ],
    );
  }

  /// The places the reader points at on the map, if they belong to [group].
  Set<String> _pointedIn(String group) => _pointed?.group == group ? _pointed!.names.toSet() : const {};

  String _caption(Lang lang) {
    if (_focused case final stop? when _section == Section.talks) {
      return '${stop.event[lang]} · ${stop.place.label(lang)} · ${formatDate(stop.date, lang)}';
    }
    return switch (_section) {
      Section.hero => MapCaption.hero[lang],
      Section.about =>
        '${MapCaption.about[lang]} · ${Places.bari.distanceKmTo(Places.pesaro).round()} km',
      Section.openSource => MapCaption.openSource[lang],
      Section.talks => MapCaption.talks[lang],
      Section.work => MapCaption.work[lang],
      Section.contact => MapCaption.contact[lang],
    };
  }

  @override
  Component build(BuildContext context) {
    final lang = _lang;
    final now = DateTime.now();

    return div(classes: 'page', [
      TopBar(lang: lang, current: _section),
      main_(classes: 'content', [
        HeroSection(lang: lang, next: nextStop(now)),
        AboutSection(lang: lang, pointed: _pointedIn(PlaceGroup.route)),
        OpenSourceSection(lang: lang, stats: _stats),
        TalksSection(
          lang: lang,
          now: now,
          focused: _focused,
          onFocus: _focus,
          onOpenDeck: _openDeck,
          pointedCities: _pointedIn(PlaceGroup.talk),
        ),
        WorkSection(lang: lang),
        ContactSection(lang: lang),
      ]),
      MapPane(
        scene: MapScene(_section, focus: _section == Section.talks ? _focused?.place : null),
        caption: _caption(lang),
        clear: _focused != null && _section == Section.talks ? (TalksCopy.showAll[lang], () => _focus(null)) : null,
        onPoint: _point,
        onSpin: _spin,
        tip: _tip(lang),
        hint: _section == Section.openSource && !_spun ? OpenSourceCopy.dragHint[lang] : null,
      ),
      if (_deck case final talk?)
        if (talk.deck case final deck?)
          SlideViewer(
            talk: talk,
            deck: deck,
            lang: lang,
            page: _slide,
            onPage: _turnTo,
            onClose: _closeDeck,
            onZoom: (zoomed) => setState(() => _zoomed = zoomed),
            zoomed: _zoomed,
            pinched: _pinched,
            fadeIn: _pushed,
          ),
    ]);
  }
}
