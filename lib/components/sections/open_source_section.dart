import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../content/copy.dart';
import '../../content/lang.dart';
import '../../content/package_stats.dart';
import '../../content/scene.dart';
import 'shared.dart';

class OpenSourceSection extends StatelessComponent {
  const OpenSourceSection({required this.lang, required this.stats, super.key});

  final Lang lang;

  /// Downloads and stars, from the build and then from the browser.
  final PackageStats stats;

  @override
  Component build(BuildContext context) {
    final (yearsValue, yearsLabel) = OpenSourceCopy.years;
    final figures = [
      (approxDownloads(stats.monthlyDownloads, lang), OpenSourceCopy.downloadsLabel),
      (approxStars(stats.stars, lang), OpenSourceCopy.starsLabel),
      (yearsValue, yearsLabel),
    ];

    return sectionFrame(Section.openSource, 'open-source', [
      kicker(OpenSourceCopy.kicker, lang),
      h2(marked(OpenSourceCopy.titleBefore, OpenSourceCopy.titleMark, OpenSourceCopy.titleAfter, lang)),
      p(classes: 'lead', [.text(OpenSourceCopy.lead[lang])]),
      div(classes: 'figures', [
        for (final (figure, label) in figures)
          div(classes: 'figure', [
            span(classes: 'value', [.text(figure)]),
            span(classes: 'label', [.text(label[lang])]),
          ]),
      ]),
      p(classes: 'source', [.text(OpenSourceCopy.source[lang])]),
      ul(classes: 'facts', [
        for (final fact in OpenSourceCopy.facts) _fact(fact),
      ]),
      p(classes: 'links', [
        outLink(Links.pubDev, [.text(OpenSourceCopy.linkPubDev[lang])], classes: 'button primary'),
        outLink(Links.repo, [.text(OpenSourceCopy.linkRepo[lang])], classes: 'button'),
        outLink(Links.docs, [.text(OpenSourceCopy.linkDocs[lang])], classes: 'button'),
      ]),
    ]);
  }

  /// The fact, its lead word in front, and its numbers and source on a line
  /// of their own when it has numbers; otherwise the source follows the text.
  Component _fact(Fact fact) {
    final source = switch (fact.source) {
      (final label, final href) => <Component>[.text(' '), outLink(href, [.text(label[lang])])],
      null => <Component>[],
    };
    return li([
      if (fact.lead case final lead?) span(classes: 'lead-in', [.text('${lead[lang]}: ')]),
      .text(fact.text[lang]),
      if (fact.detail case final detail?)
        span(classes: 'detail', [.text(detail[lang]), ...source])
      else
        ...source,
    ]);
  }
}
