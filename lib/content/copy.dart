import 'lang.dart';

/// Every word on the site, in both languages.
///
/// The facts come from two places only: cv-tailor's verified facts and the
/// "Conferenze Palmisano" sheet. A number that is not there does not go here.
/// Plain English, short sentences, no em dashes.

abstract final class Links {
  /// Where the site is published. Only absolute URLs need it: the canonical
  /// link, the language alternates and the preview image for social cards.
  /// To change once there is a domain.
  static const site = 'https://gabbopalma.github.io';

  static const email = 'gabrielpalmisano63@gmail.com';
  static const github = 'https://github.com/gabbopalma';
  static const linkedin = 'https://www.linkedin.com/in/gabrielpalmisano';
  static const sessionize = 'https://sessionize.com/gabrielpalmisano';
  static const x = 'https://x.com/gabbpalma';
  static const instagram = 'https://instagram.com/gabrielpalmisano';
  static const pubDev = 'https://pub.dev/packages/maplibre_gl';
  static const repo = 'https://github.com/maplibre/flutter-maplibre-gl';
  static const docs = 'https://maplibre.org/flutter-maplibre-gl/';
  static const interopBlog = 'https://blog.flutter.dev/flutters-path-towards-seamless-interop-4bf7d4579d9a';
  static const ebworld = 'https://www.ebw.it/';
}

abstract final class Meta {
  static const title = Txt(
    'Gabriel Palmisano · Flutter, maps and MapLibre',
    'Gabriel Palmisano · Flutter, mappe e MapLibre',
  );
  static const description = Txt(
    'Flutter developer from Bari, Italy. Lead maintainer of maplibre_gl, the '
        'Flutter package of MapLibre. Talks, open source and work.',
    'Flutter developer di Bari. Lead maintainer di maplibre_gl, il pacchetto '
        'Flutter di MapLibre. Talk, open source e lavoro.',
  );
}

abstract final class NavCopy {
  static const about = Txt('About', 'Chi sono');
  static const openSource = Txt('Open source', 'Open source');
  static const talks = Txt('Talks', 'Talk');
  static const work = Txt('Work', 'Lavoro');
  static const contact = Txt('Contact', 'Contatti');
  static const switchTo = Txt('Leggi in italiano', 'Read in English');
}

abstract final class HeroCopy {
  static const where = Txt('41.12°N, 16.87°E · Bari, Italy', '41.12°N, 16.87°E · Bari, Italia');
  static const role = Txt.same('Flutter Developer · Maps & Geospatial · MapLibre Lead Maintainer');

  /// Split around the one highlighted word.
  static const leadBefore = Txt('I build Flutter apps with ', 'Costruisco app Flutter con dentro le ');
  static const leadMark = Txt('maps', 'mappe');
  static const leadAfter = Txt(
    ' inside, and I maintain maplibre_gl, the Flutter package of MapLibre.',
    ', e mantengo maplibre_gl, il pacchetto Flutter di MapLibre.',
  );

  static const nowLabel = Txt('Now', 'Adesso');
  static const now = Txt(
    'Building a dart:ffi engine for maplibre_gl.',
    'Sto costruendo un motore dart:ffi per maplibre_gl.',
  );
  static const nextLabel = Txt('Next stop', 'Prossima tappa');

  static const ctaTalks = Txt('See my talks', 'Guarda i miei talk');
  static const ctaContact = Txt('Say hi', 'Scrivimi');
}

abstract final class AboutCopy {
  static const kicker = Txt('About', 'Chi sono');
  static const title = Txt("Hi, I'm Gabriel.", 'Ciao, sono Gabriel.');
  static const paragraphs = [
    Txt(
      "I live in Noicattaro, near Bari. I've been writing code since I was a "
          'kid, because I wanted to see how far a technology could go.',
      'Vivo a Noicattaro, vicino Bari. Scrivo codice da quando ero piccolo, '
          'perché volevo capire fin dove arriva una tecnologia.',
    ),
    Txt(
      'Maps came later and never left. Every time I see one, I ask myself: '
          'which map is that?',
      'Le mappe sono arrivate dopo e non se ne sono più andate. Ogni volta '
          'che ne vedo una mi chiedo: che mappa è?',
    ),
    Txt(
      "Today I'm a Mobile Developer at EBWorld, and most of what I build ends "
          'up in the hands of people who work in the field.',
      'Oggi sono Mobile Developer in EBWorld, e quasi tutto quello che '
          'costruisco finisce in mano a chi lavora sul campo.',
    ),
    Txt(
      'I like traveling. That helps, because I also like speaking at '
          'conferences.',
      'Mi piace viaggiare. Torna utile, perché mi piace anche parlare alle '
          'conferenze.',
    ),
  ];

  static const bari = Txt('Where I live', 'Dove vivo');
  static const pesaro = Txt('EBWorld, where I work', 'EBWorld, dove lavoro');
  static const north = Txt('km north', 'km a nord');

  static const stackTitle = Txt('What I work with', 'Con cosa lavoro');
  static const stack = <(Txt, String)>[
    (Txt('Every day', 'Ogni giorno'), 'Dart, Flutter, MapLibre, GeoJSON, Provider, Dio, Melos'),
    (Txt('Maps', 'Mappe'), 'MapLibre GL, Google Maps SDK, flutter_map, offline geometry editing'),
    (Txt('Native', 'Nativo'), 'Kotlin, Java, Swift, Objective-C'),
    (Txt('Web', 'Web'), 'TypeScript, Angular, JavaScript'),
    (Txt('AI', 'AI'), 'Claude Code, MCP, agentic testing, Amazon Bedrock'),
    (Txt('Tooling', 'Strumenti'), 'Git, GitHub Actions, Maestro, Firebase'),
  ];
}

abstract final class OpenSourceCopy {
  static const kicker = Txt('Open source', 'Open source');
  static const titleBefore = Txt('I maintain the ', 'Mantengo la ');
  static const titleMark = Txt('map', 'mappa');
  static const titleAfter = Txt(" you're looking at.", ' che stai guardando.');
  static const lead = Txt(
    'maplibre_gl is the official Flutter package of MapLibre: vector maps on '
        'Android, iOS and the web, custom styles, offline regions, and no API '
        'key.',
    'maplibre_gl è il pacchetto Flutter ufficiale di MapLibre: mappe '
        'vettoriali su Android, iOS e web, stili personalizzati, regioni '
        'offline, e nessuna API key.',
  );

  /// The first two figures come from [PackageStats]; the third is history,
  /// not a metric, so it is written down.
  static const downloadsLabel = Txt('downloads a month on pub.dev', 'download al mese su pub.dev');
  static const starsLabel = Txt('stars on GitHub', 'stelle su GitHub');
  static const years = ('~3', Txt('years from contributor to lead maintainer', 'anni da contributor a lead maintainer'));
  static const source = Txt(
    'From pub.dev and GitHub, rounded down.',
    'Da pub.dev e GitHub, arrotondati per difetto.',
  );

  static const facts = [
    Txt('Elected MapLibre Voting Member.', 'Eletto Voting Member di MapLibre.'),
    Txt(
      "A pilot package in the Flutter team's Native Interop Early Access Program.",
      'Tra i pacchetti pilota del Native Interop Early Access Program del team Flutter.',
    ),
    Txt(
      'Next: a dart:ffi engine. Same Dart API, with the MapLibre core reached '
          'directly through a C ABI.',
      'Il prossimo passo: un motore dart:ffi. Stessa API Dart, con il core di '
          'MapLibre raggiunto direttamente tramite una C ABI.',
    ),
  ];

  static const interopLink = Txt('Read it on the Flutter blog', 'Leggilo sul blog di Flutter');
  static const linkPubDev = Txt.same('pub.dev');
  static const linkRepo = Txt.same('GitHub');
  static const linkDocs = Txt('Docs', 'Documentazione');
}

abstract final class TalksCopy {
  static const kicker = Txt('Talks', 'Talk');
  static const title = Txt('On stage', 'Sul palco');
  static const talksGiven = Txt('talks', 'interventi');
  static const people = Txt('people in the room', 'persone in sala');
  static const cities = Txt('cities', 'città');
  static const hint = Txt(
    'Point at a stop and the map takes you there.',
    'Scegli una tappa e la mappa ti ci porta.',
  );
  static const upcoming = Txt('upcoming', 'in arrivo');
  static const inviteBefore = Txt('Want a talk at your event? ', 'Vuoi un talk al tuo evento? ');
  static const inviteLink = Txt('My sessions are on Sessionize.', 'Le mie sessioni sono su Sessionize.');
}

class Job {
  const Job({
    required this.company,
    required this.role,
    required this.dates,
    required this.where,
    required this.points,
  });

  final String company;
  final Txt role;
  final Txt dates;
  final Txt where;
  final List<Txt> points;
}

abstract final class WorkCopy {
  static const kicker = Txt('Work', 'Lavoro');
  static const titleBefore = Txt('Bringing ', 'Portare le ');
  static const titleMark = Txt('maps', 'mappe');
  static const titleAfter = Txt(' out of the office.', " fuori dall'ufficio.");

  static const jobs = [
    Job(
      company: 'EBWorld',
      role: Txt.same('Mobile Developer & Business Analyst'),
      dates: Txt('Sep 2024 – today', 'set 2024 – oggi'),
      where: Txt('Remote', 'Da remoto'),
      points: [
        Txt(
          'I build Geo4B Mobile, a Flutter GIS app that field crews in telco, '
              'water and energy use on site, offline too.',
          "Sviluppo Geo4B Mobile, un'app GIS in Flutter che le squadre sul "
              'campo di telco, idrico ed energia usano sul posto, anche offline.',
        ),
        Txt(
          'I moved the map from per-object to data-driven rendering: from '
              'about 3,700 to 50,000+ features on one map, in production since 2024.',
          'Ho portato la mappa da un rendering per oggetto a uno data-driven: '
              'da circa 3.700 a oltre 50.000 feature su una mappa, in '
              'produzione dal 2024.',
        ),
        Txt(
          'I follow requirements end to end, from analysis and HLD to '
              'release, and I help the company adopt AI.',
          "Seguo i requisiti end to end, dall'analisi e dall'HLD fino al "
              "rilascio, e aiuto l'azienda ad adottare l'AI.",
        ),
      ],
    ),
    Job(
      company: 'ALTEN Italia',
      role: Txt.same('Flutter Developer'),
      dates: Txt('Mar 2023 – Sep 2024', 'mar 2023 – set 2024'),
      where: Txt.same('Bari'),
      points: [
        Txt(
          'At EBWorld as a consultant: moved a native Android app to Flutter '
              'for Android and iOS, with offline sync, geometry editing and map SDKs.',
          'In EBWorld come consulente: ho portato un\'app Android nativa a '
              'Flutter per Android e iOS, con sync offline, editing geometrico '
              'e SDK di mappe.',
        ),
      ],
    ),
    Job(
      company: 'ALTEN Italia',
      role: Txt.same('.NET Developer'),
      dates: Txt('Dec 2022 – Mar 2023', 'dic 2022 – mar 2023'),
      where: Txt.same('Bari'),
      points: [
        Txt(
          'A C# portal for onboarding candidates: interviews, automated coding '
              'tests and results.',
          'Un portale C# per l\'onboarding dei candidati: colloqui, test '
              'tecnici automatici e risultati.',
        ),
      ],
    ),
    Job(
      company: 'MAV Reality',
      role: Txt.same('Junior Developer'),
      dates: Txt('Jul – Sep 2022', 'lug – set 2022'),
      where: Txt.same('Rutigliano'),
      points: [
        Txt(
          'My first Flutter apps, with PHP and SQL backends.',
          'Le mie prime app Flutter, con backend PHP e SQL.',
        ),
      ],
    ),
  ];

  static const studiesTitle = Txt('Studies', 'Formazione');
  static const studies = [
    Txt(
      'Corporate Communication and Public Speaking, POLIMI Graduate School of Management, 2025',
      'Corporate Communication and Public Speaking, POLIMI Graduate School of Management, 2025',
    ),
    Txt(
      'Diploma in Business Information Systems, 93/100, 2022',
      'Diploma in Sistemi Informativi Aziendali, 93/100, 2022',
    ),
  ];
}

abstract final class ContactCopy {
  static const kicker = Txt('Contact', 'Contatti');
  static const title = Txt('Say hi.', 'Scrivimi.');
  static const lead = Txt(
    'For a talk, for open source, or for a coffee in Bari.',
    "Per un talk, per l'open source, o per un caffè a Bari.",
  );
  static const channels = <(String, String, String)>[
    ('GitHub', 'gabbopalma', Links.github),
    ('LinkedIn', 'gabrielpalmisano', Links.linkedin),
    ('Sessionize', 'gabrielpalmisano', Links.sessionize),
    ('X', '@gabbpalma', Links.x),
    ('Instagram', 'gabrielpalmisano', Links.instagram),
  ];
  static const footer = Txt(
    'Built with Jaspr, Flutter and maplibre_gl. Map data: Natural Earth.',
    'Fatto con Jaspr, Flutter e maplibre_gl. Dati della mappa: Natural Earth.',
  );
}

/// The line under the map, one per scene: the map locates, the caption names.
abstract final class MapCaption {
  static const hero = Txt(
    'Which map is that? maplibre_gl, running live. I maintain it.',
    'Che mappa è? maplibre_gl, dal vivo. La mantengo io.',
  );
  static const about = Txt('Bari to Pesaro', 'Da Bari a Pesaro');
  static const openSource = Txt('Same map, same package.', 'Stessa mappa, stesso pacchetto.');
  static const talks = Txt('Every city I spoke in', 'Le città dove ho parlato');
  static const work = Txt('Pesaro, EBWorld', 'Pesaro, EBWorld');
  static const contact = Txt('Bari, home', 'Bari, casa');
}
