import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../content/copy.dart';
import '../../content/lang.dart';
import '../../content/scene.dart';
import 'shared.dart';

class WorkSection extends StatelessComponent {
  const WorkSection({required this.lang, super.key});

  final Lang lang;

  @override
  Component build(BuildContext context) {
    return sectionFrame(Section.work, 'work', [
      kicker(WorkCopy.kicker, lang),
      h2(marked(WorkCopy.titleBefore, WorkCopy.titleMark, WorkCopy.titleAfter, lang)),
      ol(classes: 'jobs', [
        for (final job in WorkCopy.jobs)
          li(classes: 'job', [
            div(classes: 'job-head', [
              h3([.text(job.company)]),
              span(classes: 'role', [.text(job.role[lang])]),
            ]),
            p(classes: 'meta', [.text('${job.dates[lang]} · ${job.where[lang]}')]),
            ul([for (final point in job.points) li([.text(point[lang])])]),
          ]),
      ]),
      h3([.text(WorkCopy.studiesTitle[lang])]),
      ul(classes: 'studies', [
        for (final study in WorkCopy.studies) li([.text(study[lang])]),
      ]),
    ]);
  }
}
