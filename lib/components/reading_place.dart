import 'dart:async';

import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

/// Where the reader is, carried across the switch to the other language.
///
/// The two pages have the same structure and different text, so a scroll
/// offset in pixels would land somewhere else. What carries over is the
/// block under the reading line: its section, its place among the section's
/// blocks, and how far into it the line falls. The other page puts the same
/// block at the same height on screen.
abstract final class ReadingPlace {
  static const _key = 'reading-place';

  /// The blocks a reader's eye rests on, the same in both languages.
  static const _blocks = 'h2, h3, p, li, article, dl, dt, dd';

  /// A quarter of the way down the screen, under the bar: where the eye
  /// is, more than the top edge.
  static double get _line => web.window.innerHeight * 0.25;

  /// Notes the spot in the section with [anchor], just before leaving.
  static void keep(String anchor) {
    final section = web.document.getElementById(anchor);
    if (section == null) return;
    final line = _line;
    final blocks = section.querySelectorAll(_blocks);
    var index = -1;
    var into = line - section.getBoundingClientRect().top;
    for (var i = 0; i < blocks.length; i++) {
      final top = (blocks.item(i)! as web.Element).getBoundingClientRect().top;
      if (top > line) break;
      index = i;
      into = line - top;
    }
    try {
      web.window.sessionStorage.setItem(_key, '$anchor|$index|${into.round()}');
    } catch (_) {
      // No storage, as in some private windows: the link's # still lands
      // on the section.
    }
  }

  /// On arrival, back to the spot noted on the other page, if there is one,
  /// once the fonts have given the text its final height.
  static void restore() {
    String? kept;
    try {
      kept = web.window.sessionStorage.getItem(_key);
      web.window.sessionStorage.removeItem(_key);
    } catch (_) {}
    final parts = kept?.split('|');
    if (parts == null || parts.length != 3) return;
    final index = int.tryParse(parts[1]);
    final into = int.tryParse(parts[2]);
    if (index == null || into == null) return;

    unawaited(
      web.document.fonts.ready.toDart.then((_) {
        final section = web.document.getElementById(parts[0]);
        if (section == null) return;
        final blocks = section.querySelectorAll(_blocks);
        final target = index >= 0 && index < blocks.length ? blocks.item(index)! as web.Element : section;
        final top = target.getBoundingClientRect().top + web.window.scrollY;
        web.window.scrollTo(web.ScrollToOptions(top: top + into - _line, behavior: 'instant'));
      }),
    );
  }
}
