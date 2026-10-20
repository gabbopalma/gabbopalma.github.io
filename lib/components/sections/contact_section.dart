import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../content/copy.dart';
import '../../content/lang.dart';
import '../../content/scene.dart';
import '../icons.dart';
import 'shared.dart';

class ContactSection extends StatelessComponent {
  const ContactSection({required this.lang, super.key});

  final Lang lang;

  static const _icons = {
    'GitHub': BrandIcon.github,
    'LinkedIn': BrandIcon.linkedin,
    'Sessionize': BrandIcon.sessionize,
    'X': BrandIcon.x,
    'Instagram': BrandIcon.instagram,
  };

  @override
  Component build(BuildContext context) {
    return sectionFrame(Section.contact, 'contact', [
      kicker(ContactCopy.kicker, lang),
      h2([.text(ContactCopy.title[lang])]),
      p(classes: 'lead', [.text(ContactCopy.lead[lang])]),
      a(href: 'mailto:${Links.email}', classes: 'email', [.text(Links.email)]),
      dl(classes: 'rows channels', [
        for (final (name, handle, href) in ContactCopy.channels)
          div(classes: 'row', [
            dt([?_icons[name]?.call(size: 14), .text(name)]),
            dd([outLink(href, [.text(handle)])]),
          ]),
      ]),
      footer(classes: 'colophon', [
        p([.text(ContactCopy.footer[lang])]),
        p([.text('© ${DateTime.now().year} Gabriel Palmisano')]),
      ]),
    ]);
  }
}
