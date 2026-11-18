class LyricLine {
  final Duration time;
  final String text;

  const LyricLine({
    required this.time,
    required this.text,
  });
}

class LrcParser {
  LrcParser._();

  static final RegExp _timeRegex = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\]');

  /// Parse .lrc string into chronological LyricLine list
  static List<LyricLine> parse(String lrcContent) {
    final lines = lrcContent.split('\n');
    final result = <LyricLine>[];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final matches = _timeRegex.allMatches(line);
      if (matches.isEmpty) continue;

      final lyricText = line.replaceAll(_timeRegex, '').trim();

      for (final match in matches) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
        final fractionStr = match.group(3) ?? '0';
        final milliseconds = int.tryParse(fractionStr.padRight(3, '0').substring(0, 3)) ?? 0;

        final duration = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );

        result.add(LyricLine(time: duration, text: lyricText));
      }
    }

    result.sort((a, b) => a.time.compareTo(b.time));
    return result;
  }
}
