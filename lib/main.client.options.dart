// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:maplibre_gl_web/maplibre_gl_web.dart' as _maplibre_gl_web;
import 'package:portfolio/components/site_page.dart' deferred as _site_page;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  initialize: () {
    final Registrar registrar = webPluginRegistrar;
    _maplibre_gl_web.MapLibreMapPlugin.registerWith(registrar);
    registrar.registerMessageHandler();
  },
  clients: {
    'site_page': ClientLoader(
      (p) => _site_page.SitePage(
        langCode: p['langCode'] as String,
        downloads: p['downloads'] as int,
        stars: p['stars'] as int,
      ),
      loader: _site_page.loadLibrary,
    ),
  },
);
