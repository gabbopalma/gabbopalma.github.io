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
import 'top_bar.dart';

/// The whole page, in one language.
///
/// Pre-rendered to HTML at build time, so the text is there before any
/// script runs, then brought to life on the client: it watches the scroll to
/// know which section the reader is on, and hands that to the map.
@client
class SitePage extends StatefulComponent {
  const SitePage({required this.langCode, required this.downloads, required this.stars, super.key});

  /// A string rather than a [Lang], because a client component's parameters
  /// travel from the server to the browser inside the HTML.
  final String langCode;

  /// The package numbers as the build read them. See [PackageStats].
  final int downloads;
  final int stars;

  @override
  State<SitePage> createState() => SitePageState();
}

class SitePageState extends State<SitePage> {
  Section _section = Section.hero;
  Stop? _focused;

  /// The dot on the map under the pointer, if any.
  PointedPlace? _pointed;

  late PackageStats _stats = PackageStats(monthlyDownloads: component.downloads, stars: component.stars);

  JSFunction? _onScroll;
  bool _frameRequested = false;

  Lang get _lang => Lang.fromCode(component.langCode);

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;

    _onScroll = ((web.Event _) => _scheduleDetect()).toJS;
    web.window.addEventListener('scroll', _onScroll, web.AddEventListenerOptions(passive: true));
    web.window.addEventListener('resize', _onScroll);
    _scheduleDetect();

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
          pointedCities: _pointedIn(PlaceGroup.talk),
        ),
        WorkSection(lang: lang),
        ContactSection(lang: lang),
      ]),
      MapPane(
        scene: MapScene(_section, focus: _section == Section.talks ? _focused?.place : null),
        caption: _caption(lang),
        onPoint: _point,
        tip: _tip(lang),
      ),
    ]);
  }
}
