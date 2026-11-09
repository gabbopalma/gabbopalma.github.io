import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../../content/copy.dart';
import '../../content/lang.dart';
import '../../content/scene.dart';
import '../../content/talks.dart';
import 'shared.dart';

class TalksSection extends StatelessComponent {
  const TalksSection({
    required this.lang,
    required this.now,
    required this.focused,
    required this.onFocus,
    required this.onOpenDeck,
    required this.onOpenVideo,
    this.pointedCities = const {},
    super.key,
  });

  /// Opens a talk's slides in the viewer.
  final void Function(Talk talk) onOpenDeck;

  /// Plays the recording of a talk made at one of its stops.
  final void Function(Talk talk, Stop stop) onOpenVideo;

  /// [Place.name] of the dots the reader points at on the map: every stop in
  /// those cities lights up, the other way round from [onFocus].
  final Set<String> pointedCities;

  final Lang lang;
  final DateTime now;

  /// The stop the reader is pointing at, if any.
  final Stop? focused;

  /// Called with a stop when the reader points at it, and with null when
  /// they leave the list. The map follows.
  final void Function(Stop? stop) onFocus;

  @override
  Component build(BuildContext context) {
    final stats = TalkStats(now);

    return sectionFrame(Section.talks, 'talks', [
      kicker(TalksCopy.kicker, lang),
      h2([.text(TalksCopy.title[lang])]),
      p(classes: 'stats', [
        _stat(formatNumber(stats.talksGiven, lang), TalksCopy.talksGiven),
        // Counted heads are approximate by nature: rounded, like the ~3 years.
        _stat(approxPeople(stats.people, lang), TalksCopy.people),
        _stat(formatNumber(stats.cities, lang), TalksCopy.cities),
      ]),
      p(classes: 'hint', [.text(TalksCopy.hint[lang])]),
      div(
        classes: 'talk-list',
        events: {'mouseleave': (_) => onFocus(null)},
        [for (final talk in talks) _talk(talk)],
      ),
      p(classes: 'invite', [
        .text(TalksCopy.inviteBefore[lang]),
        outLink(Links.sessionize, [.text(TalksCopy.inviteLink[lang])]),
      ]),
    ]);
  }

  Component _stat(String value, Txt label) => span(classes: 'stat', [
    span(classes: 'value', [.text(value)]),
    .text(' ${label[lang]}'),
  ]);

  Component _talk(Talk talk) {
    return article(classes: 'talk', [
      div(classes: 'talk-head', [
        h3([.text(talk.title)]),
        span(classes: 'tag', attributes: {'title': talk.language == 'EN' ? 'English' : 'Italiano'}, [
          .text(talk.language),
        ]),
      ]),
      p(classes: 'summary', [.text(talk.summary[lang])]),
      if (talk.deck != null || talk.recorded.isNotEmpty)
        div(classes: 'talk-media', [
          if (talk.deck case final deck?) _deck(talk, deck),
          for (final stop in talk.recorded) _video(talk, stop),
        ]),
      ol(classes: 'stops', [for (final stop in talk.stops) _stop(stop)]),
    ]);
  }

  /// A plain click opens [open] in place; a click with a modifier, or the
  /// middle button, follows the link itself.
  static Map<String, void Function(web.Event)> _inPlace(void Function() open) => {
    'click': (event) {
      final click = event as web.MouseEvent;
      if (click.button != 0 || click.metaKey || click.ctrlKey || click.shiftKey || click.altKey) return;
      click.preventDefault();
      open();
    },
  };

  static Component _thumb(String src) => img(
    src: src,
    alt: '',
    attributes: {'width': '640', 'height': '360', 'loading': 'lazy', 'decoding': 'async'},
  );

  /// The way into a talk's slides: its cover, small, and how many there are.
  /// A link to the deck's own page.
  Component _deck(Talk talk, Deck deck) => a(
    href: deck.path(lang),
    classes: 'deck-open',
    attributes: {
      'aria-haspopup': 'dialog',
      'data-deck': deck.id,
      'data-count': 'slides/${deck.id}',
    },
    events: _inPlace(() => onOpenDeck(talk)),
    [
      span(classes: 'deck-thumb', [_thumb(deck.cover)]),
      span(classes: 'deck-label', [
        span(classes: 'deck-title', [.text(TalksCopy.openSlides[lang])]),
        span(classes: 'deck-meta', [.text('${deck.pages} ${TalksCopy.slides[lang]} · PDF')]),
      ]),
    ],
  );

  /// A triangle pointing right, a little heavier on its left like a play
  /// button's.
  static const _play = 'M8 5.5v13l10.5-6.5z';

  /// The way into a recording, beside the slides: a frame of it with a play
  /// mark, and how long it runs. A link to the video on YouTube; the event
  /// it was filmed at is in the tooltip and on the player's bar.
  Component _video(Talk talk, Stop stop) {
    final recording = stop.recording!;
    return a(
      href: recording.watch,
      target: .blank,
      classes: 'deck-open',
      attributes: {
        'rel': 'noopener',
        'aria-haspopup': 'dialog',
        'title': stop.event[lang],
        'data-video': recording.id,
        'data-count': 'video/${recording.id}',
      },
      events: _inPlace(() => onOpenVideo(talk, stop)),
      [
        span(classes: 'deck-thumb', [
          _thumb(recording.poster),
          span(classes: 'deck-play', [
            svg(viewBox: '0 0 24 24', attributes: {'aria-hidden': 'true'}, [path(d: _play, [])]),
          ]),
        ]),
        span(classes: 'deck-label', [
          span(classes: 'deck-title', [.text(TalksCopy.watch[lang])]),
          span(classes: 'deck-meta', [.text('${formatMinutes(recording.minutes)} · YouTube')]),
        ]),
      ],
    );
  }

  /// A mouse, where pointing is free; on a phone pointing means tapping.
  static bool get _canHover => kIsWeb && web.window.matchMedia('(hover: hover)').matches;

  Component _stop(Stop stop) {
    final upcoming = !stop.isPastAt(now);
    final selected = identical(stop, focused);
    final isFocused = selected || pointedCities.contains(stop.place.name);

    // A touch fires mouseenter, then focus, then click, all for one tap, so
    // each event only selects for the input it belongs to: hover for a
    // mouse, focus for the keyboard, click for a finger. The click is also
    // the way out on a phone: tapping the selected stop again lets it go.
    void hover(web.Event _) {
      if (_canHover) onFocus(stop);
    }

    void keyboard(web.Event event) {
      if ((event.target as web.Element).matches(':focus-visible')) onFocus(stop);
    }

    void tap(web.Event event) {
      onFocus(_canHover || !selected ? stop : null);
      // A click is not a keyboard visit: let the row go, or after any key
      // press Chrome draws the keyboard focus ring on it and it stays there
      // after the selection has moved on.
      (event.currentTarget as web.HTMLElement?)?.blur();
    }

    return li(
      classes: ['stop', if (upcoming) 'upcoming', if (isFocused) 'focused'].join(' '),
      attributes: {'tabindex': '0', 'aria-pressed': '$selected'},
      events: {'mouseenter': hover, 'focus': keyboard, 'click': tap},
      [
        span(classes: 'date', [.text(formatDate(stop.date, lang))]),
        span(classes: 'event', [.text(stop.event[lang])]),
        span(classes: 'city', [.text(stop.place.label(lang))]),
        if (upcoming || stop.links.isNotEmpty)
          span(classes: 'extra', [
            if (upcoming) span(classes: 'badge', [.text(TalksCopy.upcoming[lang])]),
            for (final (label, href) in stop.links) outLink(href, [.text(label[lang])]),
          ]),
      ],
    );
  }
}
