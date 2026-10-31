import 'dart:convert';

import 'content/copy.dart';

/// What each link is called in the counts. A link not listed here, like a
/// talk's recording, goes by its address.
const _names = {
  'mailto:${Links.email}': 'email',
  Links.github: 'github',
  Links.linkedin: 'linkedin',
  Links.sessionize: 'sessionize',
  Links.x: 'x',
  Links.instagram: 'instagram',
  Links.pubDev: 'pub.dev',
  Links.repo: 'repo',
  Links.docs: 'docs',
  Links.interopBlog: 'interop-blog',
  Links.ffiPullRequest: 'pr-906',
  Links.ebworld: 'ebworld',
};

/// Counts the clicks that leave the site as GoatCounter events, and the
/// ones on anything marked `data-count`.
///
/// A link that leaves is named by where it goes and the section it was in,
/// like `click/sessionize/talks`, so the dashboard shows which links people
/// follow and from where. A marked element is counted under its own name,
/// like `slides/agentic-testing`. Plain JavaScript in the head, listening on
/// the document: it counts before the page is hydrated and whatever the page
/// re-renders. Like the page views, GoatCounter sends nothing from localhost.
String clickCounterScript() => '''
(function () {
  var names = ${jsonEncode(_names)};
  function count(event) {
    if (!event.target.closest) return;
    var counter = window.goatcounter;
    if (!counter || !counter.count) return;
    var marked = event.target.closest('[data-count]');
    if (marked) {
      counter.count({
        path: marked.getAttribute('data-count'),
        title: marked.getAttribute('title') || marked.innerText.replace(/\\s+/g, ' ').trim(),
        event: true,
      });
      return;
    }
    var link = event.target.closest('a[href]');
    if (!link) return;
    var mail = link.protocol === 'mailto:';
    if (!mail && link.host === location.host) return;
    var name = names[link.getAttribute('href')] ||
      (mail ? 'email' : link.hostname.replace(/^www\\./, '') + link.pathname.replace(/\\/\$/, '') + link.search);
    var section = link.closest('section[id]');
    counter.count({
      path: 'click/' + name + (section ? '/' + section.id : ''),
      title: link.getAttribute('aria-label') || link.textContent.trim(),
      event: true,
    });
  }
  document.addEventListener('click', count);
  // A middle click opens the link in a new tab without a click event.
  document.addEventListener('auxclick', function (event) {
    if (event.button === 1) count(event);
  });
})();
''';
