// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:portfolio/components/site_page.dart' as _site_page;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _site_page.SitePage: ClientTarget<_site_page.SitePage>(
      'site_page',
      params: __site_pageSitePage,
    ),
  },
);

Map<String, Object?> __site_pageSitePage(_site_page.SitePage c) => {
  'langCode': c.langCode,
  'downloads': c.downloads,
  'stars': c.stars,
  'deck': c.deck,
};
