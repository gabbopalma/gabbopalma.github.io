import 'lang.dart';
import 'places.dart';

/// One time a talk was given, or will be.
class Stop {
  const Stop({
    required this.date,
    required this.event,
    required this.place,
    this.audience,
    this.note,
    this.links = const [],
    this.booth = false,
  });

  final DateTime date;
  final Txt event;
  final Place place;

  /// People in the room for this talk, from the "Conferenze Palmisano" sheet.
  /// Not the attendance of the whole event: only the second number is his.
  final int? audience;

  final Txt? note;
  final List<(Txt, String)> links;

  /// A stand rather than a talk. Listed, never counted in the numbers.
  final bool booth;

  bool isPastAt(DateTime now) => !date.isAfter(now);
}

class Talk {
  const Talk({
    required this.title,
    required this.short,
    required this.language,
    required this.summary,
    required this.stops,
  });

  /// In the language the talk was given in, on both pages.
  final String title;

  /// A few words, for the label on the map, where a city can have two talks
  /// at the same event (Lecce: the talk and the panel).
  final Txt short;

  /// The language spoken on stage, shown as a code: EN or IT.
  final String language;
  final Txt summary;
  final List<Stop> stops;
}

/// Source: the "Conferenze Palmisano" Google Sheet, speaker rows only.
/// Attendee rows (DevFest Bari 2025, Flutter & Friends 2026) are not talks.
final talks = <Talk>[
  Talk(
    title: 'Chasing Behavioral Parity: Java, Swift and JS Interop in Flutter',
    short: Txt.same('Chasing Behavioral Parity'),
    language: 'EN',
    summary: Txt(
      'How one Dart API keeps the same map behavior on Android, iOS and the '
          'web, when every platform runs a different engine.',
      'Come una sola API Dart mantiene lo stesso comportamento della mappa su '
          'Android, iOS e web, quando ogni piattaforma ha un motore diverso.',
    ),
    stops: [
      Stop(
        date: _d(2026, 10, 9),
        event: Txt.same('flutterCon, next.app devCon'),
        place: Places.berlin,
        audience: 50,
      ),
    ],
  ),
  Talk(
    title: "L'IA che usa la tua app al posto tuo: Testing Agentico su Mobile",
    short: Txt('Agentic testing on mobile', 'Testing agentico su mobile'),
    language: 'IT',
    summary: Txt(
      'AI agents that drive a running Flutter app through the Dart VM '
          'Service, and where they fit next to a deterministic CI.',
      'Agenti AI che pilotano un\'app Flutter in esecuzione tramite il Dart '
          'VM Service, e dove si mettono accanto a una CI deterministica.',
    ),
    stops: [
      Stop(
        date: _d(2026, 4, 9),
        event: Txt('GDG Bari, April Tech Talks', 'GDG Bari, Aprile Tech Talks'),
        place: Places.bari,
        audience: 20,
      ),
      Stop(
        date: _d(2026, 6, 6),
        event: Txt.same('DevFest Vicenza'),
        place: Places.vicenza,
        audience: 40,
      ),
      Stop(
        date: _d(2026, 9, 19),
        event: Txt.same('DevFest Campobasso'),
        place: Places.campobasso,
        audience: 150,
      ),
      Stop(
        date: _d(2026, 10, 10),
        event: Txt.same('DevFest Milano'),
        place: Places.milan,
        audience: 30,
      ),
      Stop(
        date: _d(2026, 10, 17),
        event: Txt.same('DevFest Lecce'),
        place: Places.lecce,
        audience: 40,
      ),
      Stop(
        date: _d(2026, 10, 24),
        event: Txt.same('DevFest Venezia'),
        place: Places.mestre,
      ),
    ],
  ),
  Talk(
    title: "Panel sull'IA: uso quotidiano, adozione, pro e contro",
    short: Txt('AI panel', "Panel sull'IA"),
    language: 'IT',
    summary: Txt(
      'A panel on how we really use AI at work, put together on the day.',
      "Un panel su come usiamo davvero l'IA al lavoro, nato il giorno stesso.",
    ),
    stops: [
      Stop(
        date: _d(2026, 10, 17),
        event: Txt.same('DevFest Lecce'),
        place: Places.lecce,
        audience: 60,
      ),
    ],
  ),
  Talk(
    title: 'Codemotion Milano: Tech Expert on Flutter',
    short: Txt('Tech Expert on Flutter', 'Tech Expert su Flutter'),
    language: 'IT',
    summary: Txt(
      'Two days at the Flutter stand, answering questions from developers.',
      'Due giorni allo stand Flutter, a rispondere alle domande degli sviluppatori.',
    ),
    stops: [
      Stop(
        date: _d(2026, 10, 28),
        event: Txt.same('Codemotion Milano'),
        place: Places.milan,
        booth: true,
      ),
    ],
  ),
  Talk(
    title: "Eco+Eco: Ciò che non vi raccontano sull'IA",
    short: Txt.same('Eco+Eco'),
    language: 'IT',
    summary: Txt(
      'Talks on AI for students and businesses in the province of Pesaro and '
          'Urbino, closing at the University of Urbino with Confindustria '
          'Pesaro-Urbino.',
      "Interventi sull'IA per studenti e imprese nella provincia di Pesaro e "
          "Urbino, chiusi all'Università di Urbino con Confindustria "
          'Pesaro-Urbino.',
    ),
    stops: [
      Stop(
        date: _d(2025, 11, 11),
        event: Txt.same('IPSIA Giuseppe Benelli'),
        place: Places.pesaro,
        audience: 36,
      ),
      Stop(
        date: _d(2025, 11, 13),
        event: Txt.same('Istituto Omnicomprensivo Della Rovere'),
        place: Places.urbania,
        audience: 28,
      ),
      Stop(
        date: _d(2025, 11, 13),
        event: Txt.same('ITC Giuseppe Celli'),
        place: Places.cagli,
        audience: 22,
      ),
      Stop(
        date: _d(2025, 11, 14),
        event: Txt('IIS Raffaello, first round', 'IIS Raffaello, primo turno'),
        place: Places.urbino,
        audience: 60,
      ),
      Stop(
        date: _d(2025, 11, 14),
        event: Txt('IIS Raffaello, second round', 'IIS Raffaello, secondo turno'),
        place: Places.urbino,
        audience: 60,
      ),
      Stop(
        date: _d(2025, 11, 21),
        event: Txt('University of Urbino', "Università di Urbino"),
        place: Places.urbino,
        audience: 200,
        links: [
          (Txt('Recording', 'Registrazione'), 'https://www.youtube.com/watch?v=q4W2vbufdl0'),
          (Txt('Event', 'Evento'), 'https://www.uniurb.it/novita-ed-eventi/6384'),
        ],
      ),
    ],
  ),
];

DateTime _d(int year, int month, int day) => DateTime.utc(year, month, day);

/// Every stop of every talk, in date order.
List<(Talk, Stop)> get allStops {
  final stops = [
    for (final talk in talks)
      for (final stop in talk.stops) (talk, stop),
  ];
  stops.sort((a, b) => a.$2.date.compareTo(b.$2.date));
  return stops;
}

/// Every distinct place the map pins in the talks section.
List<Place> get talkPlaces => {for (final (_, stop) in allStops) stop.place}.toList();

/// The numbers under the talks heading, computed from the list above so they
/// can never disagree with it.
class TalkStats {
  TalkStats(DateTime now) {
    final given = [
      for (final (_, stop) in allStops)
        if (stop.isPastAt(now) && !stop.booth) stop,
    ];
    talksGiven = given.length;
    people = given.fold(0, (sum, stop) => sum + (stop.audience ?? 0));
    cities = {for (final stop in given) stop.place}.length;
  }

  late final int talksGiven;
  late final int people;
  late final int cities;
}

/// The first stop that has not happened yet, for the "next stop" line.
(Talk, Stop)? nextStop(DateTime now) {
  for (final entry in allStops) {
    if (!entry.$2.isPastAt(now)) return entry;
  }
  return null;
}

String formatDate(DateTime date, Lang lang) {
  const en = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const it = ['gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'];
  final month = (lang == Lang.en ? en : it)[date.month - 1];
  return '${date.day} $month ${date.year}';
}

String formatNumber(int value, Lang lang) {
  final digits = value.toString();
  final separator = lang == Lang.en ? ',' : '.';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(separator);
    out.write(digits[i]);
  }
  return out.toString();
}
