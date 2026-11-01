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

  /// The site's icon, the globe g on its tile, ahead of the name. Drawn
  /// inline so the stylesheet colours it from the palette; the name next to
  /// it already says what the link is, so screen readers skip it.
  static const _mark = svg(
    viewBox: '0 0 64 64',
    classes: 'brand-mark',
    attributes: {'fill': 'none', 'stroke': '#fff', 'aria-hidden': 'true', 'focusable': 'false'},
    [
      rect(width: '64', height: '64', rx: '14', classes: 'brand-tile', []),
      circle(cx: '31', cy: '24', r: '13', strokeWidth: '4.5', []),
      ellipse(cx: '31', cy: '24', rx: '5.5', ry: '13', strokeWidth: '2.2', attributes: {'opacity': '.7'}, []),
      path(d: 'M18 24h26', strokeWidth: '2.2', attributes: {'opacity': '.7'}, []),
      path(
        d: 'M44 13v26c0 8-5.5 12-12 12H20.4',
        strokeWidth: '4.5',
        attributes: {'stroke-linecap': 'round'},
        [],
      ),
      // Bari, at the end of the tail.
      circle(cx: '20.4', cy: '51', r: '3.6', strokeWidth: '2.1', classes: 'brand-dot', []),
    ],
  );

  @override
  Component build(BuildContext context) {
    return header(classes: 'topbar', [
      a(href: '#${Section.hero.anchor}', classes: 'brand', [_mark, .text('Gabriel Palmisano')]),
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
