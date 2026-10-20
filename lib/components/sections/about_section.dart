import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../content/copy.dart';
import '../../content/lang.dart';
import '../../content/places.dart';
import '../../content/scene.dart';
import 'shared.dart';

class AboutSection extends StatelessComponent {
  const AboutSection({required this.lang, this.pointed = const {}, super.key});

  final Lang lang;

  /// [Place.name] of the route dots the reader points at on the map.
  final Set<String> pointed;

  @override
  Component build(BuildContext context) {
    final km = Places.bari.distanceKmTo(Places.pesaro).round();

    return sectionFrame(Section.about, 'about', [
      kicker(AboutCopy.kicker, lang),
      div(classes: 'about-head', [
        img(
          src: 'images/gabriel-stage.jpg',
          alt: 'Gabriel Palmisano',
          width: 120,
          height: 120,
          classes: 'portrait',
        ),
        h2([.text(AboutCopy.title[lang])]),
      ]),
      for (final paragraph in AboutCopy.paragraphs) p([.text(paragraph[lang])]),

      // The two stops the map draws while this section is on screen, in the
      // same order as the route, so the rail and the line agree.
      ol(classes: 'rail', [
        li(classes: _stopClasses(Places.bari), [
          span(classes: 'name', [.text(Places.bari.name)]),
          span(classes: 'what', [.text(AboutCopy.bari[lang])]),
        ]),
        // The way between the two stops, secondary to them: an arrow down
        // the rail and the distance, smaller and lighter than a stop.
        li(classes: 'leg', [
          span(classes: 'arrow', attributes: {'aria-hidden': 'true'}, [.text('↓')]),
          .text('$km km ${AboutCopy.toPesaro[lang]}'),
        ]),
        li(classes: _stopClasses(Places.pesaro), [
          span(classes: 'name', [.text(Places.pesaro.name)]),
          span(classes: 'what', [.text(AboutCopy.pesaro[lang])]),
        ]),
      ]),

      h3([.text(AboutCopy.stackTitle[lang])]),
      // What fills the day, larger than the rest: the emphasis is in the
      // type size, not in a box around it.
      div(classes: 'daily', [
        span(classes: 'daily-label', [.text(AboutCopy.dailyLabel[lang])]),
        p(classes: 'daily-items', [
          for (final (i, item) in AboutCopy.daily.indexed) ...[
            if (i > 0) span(classes: 'sep', [.text('·')]),
            span([.text(item[lang])]),
          ],
        ]),
      ]),
      dl(classes: 'rows stack', [
        for (final (label, items) in AboutCopy.stack)
          div(classes: 'row', [
            dt([.text(label[lang])]),
            dd([.text(items[lang])]),
          ]),
      ]),
    ]);
  }

  String _stopClasses(Place place) => pointed.contains(place.name) ? 'stop pointed' : 'stop';
}
