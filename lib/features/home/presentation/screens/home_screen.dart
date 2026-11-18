import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_music_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppleMusicSliverAppBar(
            title: 'Listen Now',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.3),
                          AppColors.surface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OFFLINE MUSIC HUB',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your Local Library',
                          style: AppTypography.title2,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Play downloaded songs, albums and custom playlists anywhere without internet.',
                          style: AppTypography.subhead,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Recently Played',
                    style: AppTypography.title3,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: AppColors.textSecondary,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No recently played tracks yet',
                          style: AppTypography.callout,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Songs you play will appear here',
                          style: AppTypography.footnote,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom padding for mini player
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }
}
