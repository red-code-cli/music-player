import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/main.dart';

void main() {
  testWidgets('App renders navigation shell and tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AppleMusicPlayerApp(),
      ),
    );

    // Verify presence of main tabs
    expect(find.text('Listen Now'), findsWidgets);
    expect(find.text('Library'), findsWidgets);
    expect(find.text('Playlists'), findsWidgets);
    expect(find.text('Search'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    // Verify mini player presence
    expect(find.text('No Track Playing'), findsOneWidget);
  });
}
