import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../content/lang.dart';
import '../../content/scene.dart';

/// The frame every section shares: an anchor the nav links to, and the
/// `data-section` the page reads to tell the map where the reader is.
Component sectionFrame(Section which, String classes, List<Component> children) => section(
  id: which.anchor,
  classes: 'section $classes',
  attributes: {'data-section': which.name},
  children,
);

/// The small mono label above a heading.
Component kicker(Txt text, Lang lang) => p(classes: 'kicker', [.text(text[lang])]);

/// A line with one word under the highlighter. One per heading at most:
/// with two it is no longer emphasis.
List<Component> marked(Txt before, Txt mark, Txt after, Lang lang) => [
  .text(before[lang]),
  span(classes: 'mark', [.text(mark[lang])]),
  .text(after[lang]),
];

/// An outbound link that opens in a new tab and does not hand the opener
/// to the page it opens. [label] names a link that shows only an icon, for
/// screen readers and as the tooltip.
Component outLink(String href, List<Component> children, {String? classes, String? label}) => a(
  href: href,
  target: .blank,
  classes: classes,
  attributes: {
    'rel': 'noopener',
    if (label != null) ...{'aria-label': label, 'title': label},
  },
  children,
);
