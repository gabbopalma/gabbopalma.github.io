import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

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
    this.pointedCities = const {},
    super.key,
  });

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
        _stat(stats.talksGiven, TalksCopy.talksGiven),
        _stat(stats.people, TalksCopy.people),
        _stat(stats.cities, TalksCopy.cities),
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

  Component _stat(int value, Txt label) => span(classes: 'stat', [
    span(classes: 'value', [.text(formatNumber(value, lang))]),
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
      ol(classes: 'stops', [for (final stop in talk.stops) _stop(stop)]),
    ]);
  }

  Component _stop(Stop stop) {
    final upcoming = !stop.isPastAt(now);
    final isFocused = identical(stop, focused) || pointedCities.contains(stop.place.name);
    void focus(Object? _) => onFocus(stop);

    return li(
      classes: ['stop', if (upcoming) 'upcoming', if (isFocused) 'focused'].join(' '),
      attributes: {'tabindex': '0'},
      events: {'mouseenter': focus, 'focus': focus, 'click': focus},
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
