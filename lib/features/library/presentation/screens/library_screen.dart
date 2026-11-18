import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_music_app_bar.dart';
import 'songs_tab.dart';
import 'albums_tab.dart';
import 'artists_tab.dart';
import 'folders_tab.dart';
import '../../../playlists/presentation/screens/playlists_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryItems = [
      (
        Icons.music_note_rounded,
        'Songs',
        'All local tracks',
        (BuildContext ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const SongsTabScreen()))
      ),
      (
        Icons.album_rounded,
        'Albums',
        'Grouped by album',
        (BuildContext ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AlbumsTabScreen()))
      ),
      (
        Icons.person_rounded,
        'Artists',
        'All music artists',
        (BuildContext ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ArtistsTabScreen()))
      ),
      (
        Icons.playlist_play_rounded,
        'Playlists',
        'Your created playlists',
        (BuildContext ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PlaylistsScreen()))
      ),
      (
        Icons.folder_rounded,
        'Folders',
        'Storage directories',
        (BuildContext ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const FoldersTabScreen()))
      ),
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
                      onTap: () => item.$4(context),
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
