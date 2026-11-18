import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/constants/app_colors.dart';
import 'package:music_player/core/constants/app_typography.dart';
import 'package:music_player/core/widgets/apple_music_app_bar.dart';
import 'package:music_player/features/playlists/domain/models/playlist_model.dart';
import 'package:music_player/features/playlists/presentation/controllers/playlists_controller.dart';
import 'package:music_player/features/library/presentation/controllers/library_controller.dart';
import 'package:music_player/features/player/presentation/controllers/player_controller.dart';
import 'package:music_player/features/playlists/presentation/screens/playlist_detail_screen.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          AppleMusicSliverAppBar(
            title: 'Playlists',
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: AppColors.accent, size: 28),
                onPressed: () => _showCreatePlaylistDialog(context, ref),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Favorites Card
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.3),
                            AppColors.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: const Text(
                            'Favorite Songs',
                            style: AppTypography.headline,
                          ),
                          subtitle: Text(
                            '${favorites.length} songs',
                            style: AppTypography.footnote,
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                          ),
                          onTap: () {
                            final allSongs = ref.read(libraryProvider).songs;
                            final favSongs = allSongs.where((s) => favorites.contains(s.id)).toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlaylistDetailScreen(
                                  title: 'Favorite Songs',
                                  songs: favSongs,
                                  isFavorites: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    'All Playlists',
                    style: AppTypography.title3,
                  ),
                  const SizedBox(height: 14),

                  if (playlists.isEmpty)
                    Container(
                      height: 140,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.playlist_add_rounded,
                            color: AppColors.textSecondary,
                            size: 38,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No playlists created yet',
                            style: AppTypography.callout,
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _showCreatePlaylistDialog(context, ref),
                            child: const Text(
                              'Tap here or + to create one',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...playlists.map((pl) => _buildPlaylistTile(context, ref, pl)),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistTile(BuildContext context, WidgetRef ref, PlaylistModel pl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.queue_music_rounded,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          title: Text(pl.name, style: AppTypography.headline),
          subtitle: Text('${pl.songCount} songs', style: AppTypography.footnote),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          onTap: () async {
            final allSongs = ref.read(libraryProvider).songs;
            final songs = await ref.read(playlistsProvider.notifier).getPlaylistSongs(pl.id, allSongs);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistDetailScreen(
                    title: pl.name,
                    playlistId: pl.id,
                    songs: songs,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('New Playlist', style: AppTypography.title2),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: 'Playlist Name',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                ref.read(playlistsProvider.notifier).createPlaylist(name);
                Navigator.pop(dialogCtx);
              }
            },
          ),
        ],
      ),
    );
  }
}
