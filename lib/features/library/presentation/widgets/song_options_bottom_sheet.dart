import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/song_artwork_widget.dart';
import '../../domain/models/song_model.dart';
import '../../../player/presentation/controllers/player_controller.dart';
import '../../../playlists/presentation/controllers/playlists_controller.dart';

class SongOptionsBottomSheet extends ConsumerWidget {
  final SongModel song;

  const SongOptionsBottomSheet({
    super.key,
    required this.song,
  });

  static void show(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SongOptionsBottomSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.read(playerControllerProvider);
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.contains(song.id);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Song Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                SongArtworkWidget(id: song.id, size: 54, borderRadius: 10),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: AppTypography.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${song.artist} • ${song.album}',
                        style: AppTypography.footnote,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          // Actions
          ListTile(
            leading: const Icon(Icons.playlist_play_rounded, color: AppColors.accent),
            title: const Text('Play Next', style: AppTypography.headline),
            onTap: () {
              playerController.playNext(song);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Playing next')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.queue_music_rounded, color: AppColors.accent),
            title: const Text('Add to Queue', style: AppTypography.headline),
            onTap: () {
              playerController.addToQueue(song);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add_rounded, color: AppColors.accent),
            title: const Text('Add to Playlist', style: AppTypography.headline),
            onTap: () {
              Navigator.pop(context);
              _showAddToPlaylistDialog(context, ref);
            },
          ),
          ListTile(
            leading: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: AppColors.accent,
            ),
            title: Text(
              isFav ? 'Remove from Favorites' : 'Add to Favorites',
              style: AppTypography.headline,
            ),
            onTap: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(song.id);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.accent),
            title: const Text('Song Details', style: AppTypography.headline),
            onTap: () {
              Navigator.pop(context);
              _showSongDetailsDialog(context);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, WidgetRef ref) {
    final playlists = ref.read(playlistsProvider);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add to Playlist', style: AppTypography.title3),
        content: playlists.isEmpty
            ? const Text(
                'No playlists found. Create one in the Playlists tab.',
                style: AppTypography.body,
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (ctx, i) {
                    final pl = playlists[i];
                    return ListTile(
                      leading: const Icon(Icons.playlist_play_rounded, color: AppColors.accent),
                      title: Text(pl.name, style: AppTypography.headline),
                      onTap: () {
                        ref.read(playlistsProvider.notifier).addSongToPlaylist(pl.id, song.id);
                        Navigator.pop(dialogCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added to "${pl.name}"')),
                        );
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.accent)),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
        ],
      ),
    );
  }

  void _showSongDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Song Details', style: AppTypography.title3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Title', song.title),
            _buildDetailRow('Artist', song.artist),
            _buildDetailRow('Album', song.album),
            _buildDetailRow('Duration', song.formattedDuration),
            _buildDetailRow('File Size', song.formattedFileSize),
            _buildDetailRow('File Path', song.filePath),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Close', style: TextStyle(color: AppColors.accent)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption1),
          const SizedBox(height: 1),
          Text(value, style: AppTypography.callout),
          const Divider(height: 8),
        ],
      ),
    );
  }
}
