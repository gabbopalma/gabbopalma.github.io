import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../content/copy.dart';
import '../../content/lang.dart';
import '../../content/scene.dart';
import '../../content/talks.dart';
import '../icons.dart';
import 'shared.dart';

class HeroSection extends StatelessComponent {
  const HeroSection({required this.lang, required this.next, super.key});

  final Lang lang;

  /// The first talk that has not happened yet: the "Now" of the page.
  final (Talk, Stop)? next;

  static const _quick = [
    (BrandIcon.github, 'GitHub', Links.github),
    (BrandIcon.linkedin, 'LinkedIn', Links.linkedin),
    (BrandIcon.sessionize, 'Sessionize', Links.sessionize),
  ];

  @override
  Component build(BuildContext context) {
    return sectionFrame(Section.hero, 'hero', [
      p(classes: 'kicker', [.text(HeroCopy.where[lang])]),
      h1([.text('Gabriel Palmisano')]),
      p(classes: 'role', [.text(HeroCopy.role[lang])]),
      p(classes: 'lead', marked(HeroCopy.leadBefore, HeroCopy.leadMark, HeroCopy.leadAfter, lang)),
      dl(classes: 'now', [
        div([
          dt([.text(HeroCopy.nowLabel[lang])]),
          dd([.text(HeroCopy.now[lang])]),
        ]),
        if (next case (_, final stop)?)
          div([
            dt([.text(HeroCopy.nextLabel[lang])]),
            dd([
              a(href: '#${Section.talks.anchor}', [
                .text('${stop.event[lang]}, ${stop.place.label(lang)}'),
              ]),
              span(classes: 'date', [.text(formatDate(stop.date, lang))]),
            ]),
          ]),
      ]),
      div(classes: 'actions', [
        a(href: '#${Section.talks.anchor}', classes: 'button primary', [
          .text(HeroCopy.ctaTalks[lang]),
        ]),
        a(href: '#${Section.contact.anchor}', classes: 'button', [
          .text(HeroCopy.ctaContact[lang]),
        ]),
        // The three places people look first, one click away.
        span(classes: 'quick', [
          for (final (icon, name, href) in _quick)
            outLink(href, [icon()], classes: 'icon-link', label: name),
        ]),
      ]),
    ]);
  }
}
