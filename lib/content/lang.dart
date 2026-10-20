/// The two languages the site is published in.
///
/// English lives at `/` and Italian at `/it/`: two static pages rather than a
/// toggle that rewrites the text in place, so each language has its own URL
/// to share and to be indexed.
enum Lang {
  en(code: 'en', path: '/'),
  it(code: 'it', path: '/it/');

  const Lang({required this.code, required this.path});

  final String code;
  final String path;

  Lang get other => this == en ? it : en;

  static Lang fromCode(String code) => code == 'it' ? it : en;
}

/// One piece of copy in both languages.
class Txt {
  const Txt(this.en, this.it);

  /// For copy that reads the same in both languages, like a product name.
  const Txt.same(String text) : en = text, it = text;

  final String en;
  final String it;

  String operator [](Lang lang) => lang == Lang.en ? en : it;
}
