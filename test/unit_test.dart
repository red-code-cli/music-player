import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/utils/formatters.dart';
import 'package:music_player/core/utils/lrc_parser.dart';
import 'package:music_player/features/library/domain/models/song_model.dart';

void main() {
  group('Formatters Tests', () {
    test('formatDuration formats seconds and minutes correctly', () {
      expect(Formatters.formatDuration(const Duration(seconds: 45)), '0:45');
      expect(Formatters.formatDuration(const Duration(minutes: 3, seconds: 24)), '3:24');
      expect(Formatters.formatDuration(const Duration(hours: 1, minutes: 12, seconds: 5)), '1:12:05');
    });

    test('formatFileSize formats byte units properly', () {
      expect(Formatters.formatFileSize(1024), '1.0 KB');
      expect(Formatters.formatFileSize(1024 * 1024 * 5), '5.0 MB');
    });
  });

  group('LRC Parser Tests', () {
    test('parses synchronized lyrics lines correctly', () {
      const sampleLrc = '''
[ti:Sample Song]
[ar:Sample Artist]
[00:12.50]First line of the song
[00:25.00]Second line of the song
[01:05.30]Third chorus line
''';
      final parsed = LrcParser.parse(sampleLrc);
      expect(parsed.length, 3);
      expect(parsed[0].text, 'First line of the song');
      expect(parsed[0].time, const Duration(seconds: 12, milliseconds: 500));
      expect(parsed[1].text, 'Second line of the song');
      expect(parsed[1].time, const Duration(seconds: 25));
      expect(parsed[2].text, 'Third chorus line');
    });
  });

  group('SongModel Tests', () {
    test('toMap and fromMap retain song integrity', () {
      const song = SongModel(
        id: 101,
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours',
        duration: 200000,
        filePath: '/storage/emulated/0/Music/blinding_lights.mp3',
        fileSize: 4500000,
        isFavorite: true,
      );

      final map = song.toMap();
      final fromMap = SongModel.fromMap(map);

      expect(fromMap.id, 101);
      expect(fromMap.title, 'Blinding Lights');
      expect(fromMap.artist, 'The Weeknd');
      expect(fromMap.isFavorite, true);
      expect(fromMap.duration, 200000);
    });
  });
}
