import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../content/copy.dart';
import '../content/lang.dart';
import '../content/talks.dart';

/// A talk's recording over the whole page, in the same dark frame as the
/// slides: the video as large as it fits, and YouTube one click away.
///
/// The player is on the page only while this is open, so YouTube hears
/// nothing from the site until the reader has asked for the video.
class VideoViewer extends StatelessComponent {
  const VideoViewer({
    required this.talk,
    required this.stop,
    required this.lang,
    required this.onClose,
    this.fadeIn = false,
    super.key,
  });

  final Talk talk;

  /// The stop it was filmed at, named on the bar.
  final Stop stop;

  final Lang lang;
  final void Function() onClose;

  /// Fades in when opened from the page, not from an address of its own.
  final bool fadeIn;

  /// An arrow out of the page, up and to the right.
  static const _out = 'M7 17L17 7M9 7h8v8';

  @override
  Component build(BuildContext context) {
    final recording = stop.recording!;

    return div(
      classes: ['viewer', 'video', if (fadeIn) 'fade-in'].join(' '),
      attributes: {'role': 'dialog', 'aria-modal': 'true', 'aria-label': talk.title, 'tabindex': '-1'},
      [
        div(classes: 'viewer-bar', [
          p(classes: 'viewer-title', [
            .text(talk.short[lang]),
            span(classes: 'viewer-where', [.text(' · ${stop.event[lang]}')]),
          ]),
          a(
            href: recording.watch,
            target: .blank,
            classes: 'viewer-youtube',
            attributes: {
              'rel': 'noopener',
              'title': TalksCopy.onYouTube[lang],
              'data-count': 'video-youtube/${recording.id}',
            },
            [
              svg(
                viewBox: '0 0 24 24',
                width: 15.px,
                height: 15.px,
                attributes: {'aria-hidden': 'true'},
                [path(d: _out, [])],
              ),
              .text('YouTube'),
            ],
          ),
          button(
            classes: 'viewer-close',
            attributes: {'type': 'button', 'aria-label': TalksCopy.close[lang], 'title': TalksCopy.close[lang]},
            onClick: onClose,
            [.text('×')],
          ),
        ]),
        // The dark around the video closes, like the cross.
        div(
          classes: 'player',
          events: {
            'click': (event) {
              if (identical(event.target, event.currentTarget)) onClose();
            },
          },
          [
            iframe(
              src: recording.embed,
              allow: 'autoplay; encrypted-media; picture-in-picture; fullscreen',
              referrerPolicy: .strictOriginWhenCrossOrigin,
              attributes: {'title': talk.title, 'allowfullscreen': ''},
              [],
            ),
          ],
        ),
      ],
    );
  }

  /// Where the page is while the video plays: the address carries it, so
  /// the back button closes the player and the address can be shared.
  static String hash(Recording recording) => '#video-${recording.id}';

  /// The recording an address points at, if any.
  static (Talk, Stop)? fromHash(String hash) {
    if (!hash.startsWith('#video-')) return null;
    final id = hash.substring('#video-'.length);
    for (final (talk, stop) in allStops) {
      if (stop.recording?.id == id) return (talk, stop);
    }
    return null;
  }
}
