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
  static const ffiPullRequest = 'https://github.com/maplibre/flutter-maplibre-gl/pull/906';
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
    'Sviluppatore Flutter a Bari e lead maintainer di maplibre_gl, il '
        'package Flutter di MapLibre. Talk, open source e lavoro.',
  );
}

abstract final class NavCopy {
  static const about = Txt('About', 'Chi sono');
  static const openSource = Txt('Open source', 'Open source');
  static const talks = Txt('Talks', 'Talk');
  static const work = Txt('Experience', 'Esperienza');
  static const contact = Txt('Contact', 'Contatti');
  static const switchTo = Txt('Leggi in italiano', 'Read in English');
}

abstract final class HeroCopy {
  static const where = Txt('41.12°N, 16.87°E · Bari, Italy', '41.12°N, 16.87°E · Bari, Italia');
  static const role = Txt.same('Flutter Developer · Maps & Geospatial · MapLibre Lead Maintainer');

  /// Split around the one highlighted word.
  static const leadBefore = Txt('I build Flutter apps with ', 'Sviluppo app Flutter in cui le ');
  static const leadMark = Txt('maps', 'mappe');
  static const leadAfter = Txt(
    ' inside, and I maintain maplibre_gl, the Flutter package of MapLibre.',
    ' sono al centro, e mantengo maplibre_gl, il package Flutter di MapLibre.',
  );

  static const nowLabel = Txt('Now', 'Adesso');
  static const now = Txt(
    'Building a dart:ffi engine for maplibre_gl.',
    'Sto lavorando a un engine dart:ffi per maplibre_gl.',
  );
  static const nextLabel = Txt('Next stop', 'Prossima tappa');

  static const ctaTalks = Txt('See my talks', 'I miei talk');
  static const ctaContact = Txt('Say hi', 'Scrivimi');
}

abstract final class AboutCopy {
  static const kicker = Txt('About', 'Chi sono');
  static const title = Txt("Hi, I'm Gabriel.", 'Ciao, sono Gabriel.');
  static const paragraphs = [
    Txt(
      "I live in Bari. I've been writing code since I was a kid, because I "
          'wanted to see how far a technology could go.',
      'Vivo a Bari e scrivo codice da quando ero bambino: volevo capire fin '
          'dove si può spingere una tecnologia.',
    ),
    Txt(
      'Maps came later and never left. Every time I see one, I ask myself: '
          'which map is that?',
      'Poi sono arrivate le mappe, e sono rimaste. Ogni volta che ne vedo una '
          'mi chiedo: che mappa è?',
    ),
    Txt(
      "Today I'm a Mobile Developer at EBWorld, and most of what I build ends "
          'up in the hands of people who work in the field.',
      'Oggi sono Mobile Developer in EBWorld, e quasi tutto quello che '
          'sviluppo finisce nelle mani di chi lavora sul campo.',
    ),
    Txt(
      'I like traveling. That helps, because I also like speaking at '
          'conferences.',
      'Mi piace viaggiare, e torna comodo: mi piace anche parlare alle '
          'conferenze.',
    ),
  ];

  static const bari = Txt('Where I live', 'Dove vivo');
  static const pesaro = Txt('EBWorld, where I work', 'EBWorld, dove lavoro');
  /// The leg between the two stops on the rail: the way from Bari to Pesaro,
  /// read downwards like the rail, so no compass word that points up.
  static const toPesaro = Txt('to Pesaro', 'fino a Pesaro');

  static const stackTitle = Txt('What I work with', 'I miei strumenti');

  /// The three things that fill the day, shown larger than the rest. No
  /// product names for the AI part: the agent of the month changes, the way
  /// of working does not.
  static const dailyLabel = Txt('Every day', 'Ogni giorno');
  static const daily = [Txt.same('Flutter & Dart'), Txt.same('maplibre_gl'), Txt.same('AI agents')];

  /// Agreed with Gabriel on 20 Oct 2026: what he really does, not every
  /// library he has touched, with his main work (Flutter, maps) first and AI
  /// right after. GitLab CI and Jira/Confluence wait for his confirmation, as
  /// cv-tailor's facts ask.
  static const stack = <(Txt, Txt)>[
    (
      Txt.same('Flutter'),
      Txt(
        'federated plugins, interop (method channels, js_interop, dart:ffi), '
            'offline-first sync, Melos monorepos',
        'plugin federati, interop (method channel, js_interop, dart:ffi), '
            'sync offline-first, monorepo con Melos',
      ),
    ),
    (
      Txt('Maps', 'Mappe'),
      Txt(
        'MapLibre Native and GL JS, GeoJSON and data-driven styles, offline '
            'geometry editing, Google Maps SDK',
        'MapLibre Native e GL JS, GeoJSON e stili data-driven, editing '
            'geometrico offline, Google Maps SDK',
      ),
    ),
    (
      Txt.same('AI'),
      Txt(
        "coding agents working in parallel under one orchestrator, skills and "
            "plugins for my team's workflows, MCP into Jira, GitLab and running "
            'apps, agentic testing of Flutter apps',
        'più coding agent in parallelo, coordinati da un orchestratore; skill '
            'e plugin per il modo di lavorare del team; MCP per collegarli a '
            'Jira, GitLab e alle app in esecuzione; agentic testing sulle app '
            'Flutter',
      ),
    ),
    (
      Txt('Platforms', 'Piattaforme'),
      Txt(
        'Java, Kotlin, Swift, JavaScript: enough to maintain the plugin on '
            'Android, iOS and the web',
        'Java, Kotlin, Swift, JavaScript: quanto basta per mantenere il plugin '
            'su Android, iOS e web',
      ),
    ),
    (
      Txt.same('Web'),
      Txt('Angular and TypeScript, Jaspr (this site)', 'Angular e TypeScript, Jaspr (questo sito)'),
    ),
    (
      Txt('On stage', 'Sul palco'),
      Txt(
        'decks written in Flutter with flutter_deck, live demos',
        'slide fatte in Flutter con flutter_deck, demo dal vivo',
      ),
    ),
    (
      Txt('With clients', 'Con i clienti'),
      Txt('requirements, HLDs and estimates', 'analisi dei requisiti, HLD e stime'),
    ),
    (
      Txt('Shipping', 'Rilasci'),
      Txt.same('GitHub Actions, Maestro, Firebase'),
    ),
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
    'maplibre_gl è il package Flutter ufficiale di MapLibre: mappe '
        'vettoriali su Android, iOS e web, stili custom, regioni '
        'offline e nessuna API key da configurare.',
  );

  /// The first two figures come from [PackageStats]; the third is history,
  /// not a metric, so it is written down.
  static const downloadsLabel = Txt('downloads a month on pub.dev', 'download al mese su pub.dev');
  static const starsLabel = Txt('stars on GitHub', 'star su GitHub');
  static const years = ('~3', Txt('years from contributor to lead maintainer', 'anni per passare da contributor a lead maintainer'));
  static const source = Txt(
    'From pub.dev and GitHub, rounded down.',
    'Da pub.dev e GitHub, arrotondati per difetto.',
  );

  static const facts = [
    Fact(Txt('Elected MapLibre Voting Member.', 'Sono stato eletto Voting Member di MapLibre.')),
    Fact(
      Txt(
        "A pilot package in the Flutter team's Native Interop Early Access Program.",
        'maplibre_gl è tra i pacchetti pilota del Native Interop Early Access '
            'Program del team Flutter.',
      ),
      source: (Txt('Read it on the Flutter blog', 'Ne parla il blog di Flutter'), Links.interopBlog),
    ),
    Fact(
      Txt(
        'an experimental dart:ffi engine for Android, behind the same Dart API.',
        'un engine dart:ffi sperimentale per Android, con la stessa API Dart di '
            'sempre.',
      ),
      lead: Txt('Next', 'Prossimo passo'),
      detail: Txt(
        'A 20,000-point GeoJSON load went from 1.46 s to about 0.15 s, and live '
            'updates from 9 to 30 a second.',
        'Caricare un GeoJSON da 20.000 punti passa da 1,46 s a circa 0,15 s, e '
            'gli aggiornamenti live da 9 a 30 al secondo.',
      ),
      source: (Txt('See PR #906 on GitHub', 'La PR #906 su GitHub'), Links.ffiPullRequest),
    ),
  ];

  static const dragHint = Txt('Drag to spin the globe', 'Trascina per far girare il globo');

  static const linkPubDev = Txt.same('pub.dev');
  static const linkRepo = Txt.same('GitHub');
  static const linkDocs = Txt('Docs', 'Documentazione');
}

/// One line in the open source list.
class Fact {
  const Fact(this.text, {this.lead, this.detail, this.source});

  final Txt text;

  /// A word set in front, a little bolder: "Next".
  final Txt? lead;

  /// A second line under the fact, for the numbers that back it.
  final Txt? detail;

  /// Where a reader can check it, linked at the end.
  final (Txt, String)? source;
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
  static const showAll = Txt('Show all talks', 'Mostra tutti i talk');
  static const inviteBefore = Txt('Want a talk at your event? ', 'Organizzi un evento? ');
  static const inviteLink = Txt('My sessions are on Sessionize.', 'Trovi le mie sessioni su Sessionize.');
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
  static const kicker = Txt('Experience', 'Esperienza');
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
          "Sviluppo Geo4B Mobile, l'app GIS in Flutter che le squadre di telco, "
              'acqua ed energia usano direttamente sul campo, anche senza rete.',
        ),
        Txt(
          'I moved the map from per-object to data-driven rendering: from '
              'about 3,700 to 50,000+ features on one map, in production since 2024.',
          'Ho riprogettato il rendering della mappa, da un oggetto alla volta a '
              'un modello data-driven: da circa 3.700 a oltre 50.000 feature '
              'sulla stessa mappa, in produzione dal 2024.',
        ),
        Txt(
          'I follow requirements end to end, from analysis and HLD to '
              'release, and I help the company adopt AI.',
          "Curo i requisiti dall'inizio alla fine, dall'analisi e dall'HLD "
              "fino al rilascio, e seguo l'adozione dell'AI in azienda.",
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
          "Da consulente in EBWorld ho riscritto in Flutter un'app Android "
              'nativa, per Android e iOS, con sync offline, editing '
              'geometrico e SDK di mappe.',
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
          'Un portale in C# per gestire i candidati: colloqui, test tecnici '
              'automatici e risultati.',
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
    "Per un talk, per l'open source o per un caffè a Bari.",
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
    'Realizzato con Jaspr, Flutter e maplibre_gl. Dati della mappa: Natural Earth.',
  );
}

/// The line under the map, one per scene: the map locates, the caption names.
abstract final class MapCaption {
  static const hero = Txt(
    'Which map is that? maplibre_gl, running live. I maintain it.',
    'Che mappa è? È maplibre_gl, il package che mantengo.',
  );
  static const about = Txt('Bari to Pesaro', 'Da Bari a Pesaro');
  static const openSource = Txt('Same map, same package.', 'Stessa mappa, stesso package.');
  static const talks = Txt('Every city I spoke in', 'Le città in cui ho parlato');
  static const work = Txt('Pesaro, EBWorld', 'Pesaro, EBWorld');
  static const contact = Txt('Bari, home', 'Bari, casa mia');
}
