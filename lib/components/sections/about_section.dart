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
          src: 'images/gabriel.jpg',
          alt: 'Gabriel Palmisano',
          width: 88,
          height: 88,
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
        li(classes: 'leg', [.text('$km ${AboutCopy.north[lang]}')]),
        li(classes: _stopClasses(Places.pesaro), [
          span(classes: 'name', [.text(Places.pesaro.name)]),
          span(classes: 'what', [.text(AboutCopy.pesaro[lang])]),
        ]),
      ]),

      h3([.text(AboutCopy.stackTitle[lang])]),
      dl(classes: 'rows stack', [
        for (final (label, items) in AboutCopy.stack)
          div(classes: 'row', [
            dt([.text(label[lang])]),
            dd([.text(items)]),
          ]),
      ]),
    ]);
  }

  String _stopClasses(Place place) => pointed.contains(place.name) ? 'stop pointed' : 'stop';
}
