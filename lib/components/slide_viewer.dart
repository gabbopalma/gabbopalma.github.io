import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../content/copy.dart';
import '../content/lang.dart';
import '../content/talks.dart';

/// A talk's slides over the whole page: one at a time, swiped on a phone,
/// arrows or keys on a desktop, and the PDF for whoever wants to keep it.
///
/// The slides sit side by side in a track that snaps to each one, so a swipe
/// is the browser's own scroll, momentum included. Where the track stands
/// decides the slide number, never the other way round: the arrows and the
/// keys only scroll it.
class SlideViewer extends StatelessComponent {
  const SlideViewer({
    required this.talk,
    required this.deck,
    required this.lang,
    required this.page,
    required this.onPage,
    required this.onClose,
    required this.onZoom,
    this.fadeIn = false,
    this.zoomed = false,
    this.pinched = false,
    super.key,
  });

  final Talk talk;
  final Deck deck;
  final Lang lang;

  /// The slide in view, from 0.
  final int page;

  final void Function(int page) onPage;
  final void Function() onClose;

  /// Fades in when opened from the page. A deck's own page starts with it
  /// open, and a fade there would only show the site through it first.
  final bool fadeIn;

  /// The slide in view is shown at twice its size, by a click, the zoom
  /// button or the + key, where there is a mouse.
  final bool zoomed;
  final void Function(bool zoomed) onZoom;

  /// The browser's own zoom is in, from a pinch on a phone. The viewer does
  /// not draw it, only holds the slide still under it.
  final bool pinched;

  /// A chevron pointing left; the next arrow is the same one turned round.
  static const _chevron = 'M15 18l-6-6 6-6';

  /// An arrow down onto a tray: the PDF is a download, not a page.
  static const _download = 'M12 4v11M7 10l5 5 5-5M5 20h14';

  /// A magnifying glass, with a plus to zoom in and a minus to zoom out.
  static const _lens = 'M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14zM20.5 20.5l-4.5-4.5M8 11h6';
  static const _plus = 'M11 8v6';

  /// Two links of a chain.
  static const _chain =
      'M10 13a5 5 0 0 0 7.5.5l3-3a5 5 0 0 0-7-7l-1.7 1.7M14 11a5 5 0 0 0-7.5-.5l-3 3a5 5 0 0 0 7 7l1.7-1.7';

  static web.HTMLElement? get _track => web.document.querySelector('.viewer-track') as web.HTMLElement?;

  /// The slide the track stands on, if it is on screen.
  static int? get _current {
    final track = _track;
    if (track == null || track.clientWidth == 0) return null;
    return (track.scrollLeft / track.clientWidth).round();
  }

  /// The slide the track is scrolling to, until it gets there or a finger
  /// takes over. Two quick presses on an arrow go two slides on from it,
  /// not twice to the slide after the one still in view.
  static int? _heading;

  /// Scrolls the track to slide [to], kept within the deck. [instant] for a
  /// link that opens on a slide: no ride through the ones before it.
  static void go(int to, {bool instant = false}) {
    final track = _track;
    if (track == null) return;
    final target = to.clamp(0, track.children.length - 1);
    _heading = target;
    final still = instant || web.window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    track.scrollTo(web.ScrollToOptions(left: target * track.clientWidth, behavior: still ? 'auto' : 'smooth'));
  }

  /// Turns [by] slides from the one in view, [page], or from the one the
  /// track is already heading to.
  static void step(int by, int page) => go((_heading ?? page) + by);

  /// A deck opens on its first slide, wherever the last one was heading.
  static void reset() => _heading = null;

  /// Zooming by click is for a mouse. A finger pinches, and the browser
  /// zooms the whole view, more smoothly than any script could.
  static bool get _canClickToZoom => web.window.matchMedia('(hover: hover) and (pointer: fine)').matches;

  /// Once the zoomed slide is drawn, scrolls it so that [at], a point of the
  /// slide in fractions of its size, sits in the middle of the view: the
  /// spot that was clicked stays under the pointer.
  static void centerSoon((double, double) at) {
    web.window.requestAnimationFrame(
      ((JSNumber _) {
        final frame = web.document.querySelector('.viewer-slide.zoomed') as web.HTMLElement?;
        final image = frame?.querySelector('img') as web.HTMLElement?;
        if (frame == null || image == null) return;
        frame.scrollLeft = image.offsetLeft + at.$1 * image.offsetWidth - frame.clientWidth / 2;
        frame.scrollTop = image.offsetTop + at.$2 * image.offsetHeight - frame.clientHeight / 2;
      }).toJS,
    );
  }

  /// A mouse dragging the zoomed slide around: where it was pressed, and
  /// where the slide stood then.
  static ({int x, int y, double left, double top})? _grab;

  /// The press became a drag, so letting go is not a click.
  static bool _dragged = false;

  void _zoomIn((double, double) at) {
    onZoom(true);
    centerSoon(at);
  }

  @override
  Component build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final first = page == 0;
    final last = page == deck.pages - 1;

    return div(
      classes: ['viewer', if (fadeIn) 'fade-in', if (zoomed || pinched) 'held'].join(' '),
      attributes: {'role': 'dialog', 'aria-modal': 'true', 'aria-label': talk.title, 'tabindex': '-1'},
      [
        div(classes: 'viewer-bar', [
          p(classes: 'viewer-title', [.text(talk.short[lang])]),
          span(classes: 'viewer-count', attributes: {'aria-live': 'polite'}, [
            .text('${two(page + 1)} / ${two(deck.pages)}'),
          ]),
          button(
            classes: 'viewer-zoom',
            attributes: {
              'type': 'button',
              'aria-pressed': '$zoomed',
              'aria-label': (zoomed ? TalksCopy.zoomOut : TalksCopy.zoomIn)[lang],
              'title': (zoomed ? TalksCopy.zoomOut : TalksCopy.zoomIn)[lang],
            },
            onClick: () => zoomed ? onZoom(false) : _zoomIn((0.5, 0.5)),
            [
              svg(
                viewBox: '0 0 24 24',
                width: 16.px,
                height: 16.px,
                attributes: {'aria-hidden': 'true'},
                [path(d: zoomed ? _lens : '$_lens$_plus', [])],
              ),
            ],
          ),
          _LinkButton(talk: talk, deck: deck, lang: lang, page: page),
          a(
            href: deck.pdf,
            classes: 'viewer-pdf',
            attributes: {
              'download': '${deck.id}.pdf',
              'title': TalksCopy.download[lang],
              'data-count': 'slides-pdf/${deck.id}',
            },
            [
              svg(
                viewBox: '0 0 24 24',
                width: 15.px,
                height: 15.px,
                attributes: {'aria-hidden': 'true'},
                [path(d: _download, [])],
              ),
              .text('PDF'),
            ],
          ),
          button(
            classes: 'viewer-close',
            attributes: {'type': 'button', 'aria-label': TalksCopy.close[lang], 'title': TalksCopy.close[lang]},
            onClick: onClose,
            [.text('×')],
          ),
        ]),
        div(
          classes: 'viewer-track',
          events: {
            'scroll': (_) {
              final at = _current;
              if (at == null) return;
              if (at == _heading) _heading = null;
              if (at != page) onPage(at);
            },
            'pointerdown': (_) => _heading = null,
            'wheel': (_) => _heading = null,
            // The dark around a slide closes, like the cross. The slide
            // itself does not: a tap on it is a reader, not a way out. With
            // a mouse, a click on it zooms in there, and the next one out.
            'click': (event) {
              final image = (event.target as web.Element).closest('img');
              if (image == null) {
                if (!zoomed) onClose();
                return;
              }
              if (_dragged) {
                _dragged = false;
                return;
              }
              if (!_canClickToZoom) return;
              if (zoomed) {
                onZoom(false);
                return;
              }
              final click = event as web.MouseEvent;
              final box = image.getBoundingClientRect();
              _zoomIn(((click.clientX - box.left) / box.width, (click.clientY - box.top) / box.height));
            },
          },
          [
            for (var i = 0; i < deck.pages; i++)
              div(classes: zoomed && i == page ? 'viewer-slide zoomed' : 'viewer-slide', events: zoomed && i == page ? _panning : null, [
                img(
                  src: deck.slide(i),
                  alt: '${TalksCopy.slide[lang]} ${i + 1} ${TalksCopy.of[lang]} ${deck.pages}',
                  attributes: {
                    // The browser takes the smallest that is sharp at the
                    // width the stylesheet gives the slide.
                    'srcset': '${deck.slide(i)} 1920w, ${deck.sharpSlide(i)} 3840w',
                    // Zoomed, the slide is twice as wide: the largest there is.
                    'sizes': zoomed && i == page
                        ? '3840px'
                        : '(max-width: 900px) calc(100vw - 24px), min(86vw, calc((100vh - 150px) * 16 / 9))',
                    'width': '1920',
                    'height': '1080',
                    'decoding': 'async',
                    'draggable': 'false',
                    // The slides around the one in view load now, so a
                    // swipe never lands on an empty frame; the rest wait.
                    'loading': (i - page).abs() <= 2 ? 'eager' : 'lazy',
                  },
                ),
              ]),
          ],
        ),
        _arrow('prev', TalksCopy.previous, hidden: first, onPressed: () => step(-1, page)),
        _arrow('next', TalksCopy.next, hidden: last, onPressed: () => step(1, page)),
        div(classes: 'viewer-progress', [
          div(
            classes: 'viewer-progress-bar',
            attributes: {'style': 'width: ${((page + 1) / deck.pages * 100).toStringAsFixed(2)}%'},
            [],
          ),
        ]),
      ],
    );
  }

  /// A mouse drags the zoomed slide around, as a hand would. The wheel and
  /// a trackpad scroll it on their own.
  static final Map<String, void Function(web.Event)> _panning = {
    'pointerdown': (event) {
      final press = event as web.PointerEvent;
      if (press.pointerType != 'mouse' || press.button != 0) return;
      final frame = press.currentTarget as web.HTMLElement;
      _grab = (x: press.clientX, y: press.clientY, left: frame.scrollLeft, top: frame.scrollTop);
      _dragged = false;
      frame
        ..setPointerCapture(press.pointerId)
        ..classList.add('grabbing');
    },
    'pointermove': (event) {
      final grab = _grab;
      if (grab == null) return;
      final move = event as web.PointerEvent;
      final dx = move.clientX - grab.x;
      final dy = move.clientY - grab.y;
      if (dx.abs() + dy.abs() > 4) _dragged = true;
      (move.currentTarget as web.HTMLElement)
        ..scrollLeft = grab.left - dx
        ..scrollTop = grab.top - dy;
    },
    'pointerup': _letGo,
    'pointercancel': _letGo,
  };

  static void _letGo(web.Event event) {
    _grab = null;
    (event.currentTarget as web.HTMLElement?)?.classList.remove('grabbing');
  }

  Component _arrow(String side, Txt label, {required bool hidden, required void Function() onPressed}) => button(
    classes: 'viewer-nav $side',
    attributes: {
      'type': 'button',
      'aria-label': label[lang],
      'title': label[lang],
      if (hidden) 'disabled': '',
    },
    onClick: onPressed,
    [
      svg(
        viewBox: '0 0 24 24',
        width: 22.px,
        height: 22.px,
        attributes: {'aria-hidden': 'true'},
        [path(d: _chevron, [])],
      ),
    ],
  );
}

/// "Link": the address of the slide in view. Copied where there is a mouse,
/// handed to the share sheet on a phone, and "Copied" for a moment after.
class _LinkButton extends StatefulComponent {
  const _LinkButton({required this.talk, required this.deck, required this.lang, required this.page});

  final Talk talk;
  final Deck deck;
  final Lang lang;
  final int page;

  @override
  State<_LinkButton> createState() => _LinkButtonState();
}

class _LinkButtonState extends State<_LinkButton> {
  bool _copied = false;
  Timer? _settle;

  @override
  void dispose() {
    _settle?.cancel();
    super.dispose();
  }

  String get _url {
    final page = component.page;
    return '${web.window.location.origin}${component.deck.path(component.lang)}${page > 0 ? '#${page + 1}' : ''}';
  }

  Future<void> _share() async {
    final url = _url;
    if (web.window.matchMedia('(hover: none)').matches) {
      try {
        await web.window.navigator.share(web.ShareData(title: component.talk.short[component.lang], url: url)).toDart;
        return;
      } catch (error) {
        // The sheet closed without sharing: nothing to do. No sheet at all,
        // as on a page served without HTTPS: copy instead.
        if (error.toString().contains('AbortError')) return;
      }
    }
    if (!await _copy(url) || !mounted) return;
    setState(() => _copied = true);
    _settle?.cancel();
    _settle = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  /// The clipboard API, or where a browser refuses it, the old way: a text
  /// box with the address, selected and copied. Inside the viewer, because
  /// the page around it is inert.
  static Future<bool> _copy(String text) async {
    try {
      await web.window.navigator.clipboard.writeText(text).toDart;
      return true;
    } catch (_) {}
    final focused = web.document.activeElement as web.HTMLElement?;
    final box = web.HTMLTextAreaElement()
      ..value = text
      ..readOnly = true;
    box.style
      ..position = 'fixed'
      ..opacity = '0';
    (web.document.querySelector('.viewer') ?? web.document.body!).append(box);
    // Safari on iOS selects a text box only through the range.
    box
      ..select()
      ..setSelectionRange(0, text.length);
    final copied = web.document.execCommand('copy');
    box.remove();
    focused?.focus();
    return copied;
  }

  @override
  Component build(BuildContext context) {
    final lang = component.lang;
    return button(
      classes: _copied ? 'viewer-link copied' : 'viewer-link',
      attributes: {
        'type': 'button',
        'title': TalksCopy.linkHint[lang],
        'data-count': 'slides-link/${component.deck.id}',
      },
      onClick: () => unawaited(_share()),
      [
        svg(
          viewBox: '0 0 24 24',
          width: 15.px,
          height: 15.px,
          attributes: {'aria-hidden': 'true'},
          [path(d: SlideViewer._chain, [])],
        ),
        span(attributes: {'aria-live': 'polite'}, [.text((_copied ? TalksCopy.copied : TalksCopy.link)[lang])]),
      ],
    );
  }
}
