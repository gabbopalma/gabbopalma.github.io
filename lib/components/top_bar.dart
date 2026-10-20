import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../content/copy.dart';
import '../content/lang.dart';
import '../content/scene.dart';

class TopBar extends StatelessComponent {
  const TopBar({required this.lang, required this.current, super.key});

  final Lang lang;

  /// The section on screen, so its link reads as the current one.
  final Section current;

  static const _links = [
    (Section.about, NavCopy.about),
    (Section.openSource, NavCopy.openSource),
    (Section.talks, NavCopy.talks),
    (Section.work, NavCopy.work),
    (Section.contact, NavCopy.contact),
  ];

  @override
  Component build(BuildContext context) {
    return header(classes: 'topbar', [
      a(href: '#${Section.hero.anchor}', classes: 'brand', [.text('Gabriel Palmisano')]),
      nav(classes: 'sections', [
        for (final (section, label) in _links)
          a(
            href: '#${section.anchor}',
            classes: section == current ? 'current' : null,
            attributes: {if (section == current) 'aria-current': 'true'},
            [.text(label[lang])],
          ),
      ]),
      a(
        href: lang.other.path,
        classes: 'lang',
        attributes: {'hreflang': lang.other.code, 'lang': lang.other.code, 'title': NavCopy.switchTo[lang]},
        [
          span(classes: lang == Lang.en ? 'on' : null, [.text('EN')]),
          span(classes: 'sep', [.text('/')]),
          span(classes: lang == Lang.it ? 'on' : null, [.text('IT')]),
        ],
      ),
    ]);
  }
}
