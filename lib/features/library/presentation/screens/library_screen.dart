import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_music_app_bar.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryItems = [
      (Icons.music_note_rounded, 'Songs', 'All local tracks'),
      (Icons.album_rounded, 'Albums', 'Grouped by album'),
      (Icons.person_rounded, 'Artists', 'All music artists'),
      (Icons.playlist_play_rounded, 'Playlists', 'Your created playlists'),
      (Icons.category_rounded, 'Genres', 'Pop, Rock, Classical, etc.'),
      (Icons.folder_rounded, 'Folders', 'Storage directories'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppleMusicSliverAppBar(
            title: 'Library',
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = libraryItems[index];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.$1,
                          color: AppColors.accent,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        item.$2,
                        style: AppTypography.headline,
                      ),
                      subtitle: Text(
                        item.$3,
                        style: AppTypography.footnote,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                        size: 24,
                      ),
                      onTap: () {
                        // Will navigate to respective tabs/screens in Phase 3
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 72, right: 20),
                      child: Divider(),
                    ),
                  ],
                );
              },
              childCount: libraryItems.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }
}
