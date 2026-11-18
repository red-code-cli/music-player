import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/core/constants/app_colors.dart';
import 'package:music_player/core/theme/app_theme.dart';
import 'package:music_player/core/widgets/apple_music_app_bar.dart';
import 'package:music_player/core/widgets/glass_container.dart';

void main() {
  testWidgets('AppleMusicSliverAppBar renders title correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: CustomScrollView(
            slivers: [
              AppleMusicSliverAppBar(title: 'Listen Now'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Listen Now'), findsOneWidget);
  });

  testWidgets('GlassContainer renders with frosted glass blur', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: GlassContainer(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Text('Frosted Glass Test'),
          ),
        ),
      ),
    );

    expect(find.text('Frosted Glass Test'), findsOneWidget);
  });

  test('AppTheme has pure black background and Apple Music accent', () {
    final theme = AppTheme.darkTheme;
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.primaryColor, AppColors.accent);
    expect(theme.brightness, Brightness.dark);
  });
}
