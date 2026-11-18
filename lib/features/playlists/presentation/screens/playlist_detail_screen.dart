import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/constants/app_colors.dart';
import 'package:music_player/core/constants/app_typography.dart';
import 'package:music_player/core/widgets/apple_music_app_bar.dart';
import 'package:music_player/core/widgets/song_artwork_widget.dart';
import 'package:music_player/features/library/domain/models/song_model.dart';
import 'package:music_player/features/library/presentation/widgets/song_options_bottom_sheet.dart';
import 'package:music_player/features/player/presentation/controllers/player_controller.dart';
import 'package:music_player/features/playlists/presentation/controllers/playlists_controller.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final int? playlistId;
  final List<SongModel> songs;
  final bool isFavorites;

  const PlaylistDetailScreen({
    super.key,
    required this.title,
    this.playlistId,
    required this.songs,
    this.isFavorites = false,
  });

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  late List<SongModel> _currentSongs;

  @override
  void initState() {
    super.initState();
    _currentSongs = List.from(widget.songs);
  }

  @override
  Widget build(BuildContext context) {
    final playerController = ref.read(playerControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          AppleMusicSliverAppBar(
            title: widget.title,
            actions: [
              if (!widget.isFavorites && widget.playlistId != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.accent),
                  color: AppColors.surface,
                  onSelected: (val) {
                    if (val == 'rename') {
                      _renamePlaylist();
                    } else if (val == 'delete') {
                      _deletePlaylist();
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'rename', child: Text('Rename Playlist')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Playlist', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
            ],
          ),
          if (_currentSongs.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No songs in this playlist', style: AppTypography.subhead),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 26),
                        label: const Text('Play All', style: AppTypography.headline),
                        onPressed: () {
                          playerController.playQueue(_currentSongs, initialIndex: 0);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.shuffle_rounded, size: 22),
                        label: const Text('Shuffle', style: AppTypography.headline),
                        onPressed: () {
                          final shuffled = List<SongModel>.from(_currentSongs)..shuffle();
                          playerController.playQueue(shuffled, initialIndex: 0);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = _currentSongs[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        leading: SongArtworkWidget(id: song.id, size: 46, borderRadius: 8),
                        title: Text(
                          song.title,
                          style: AppTypography.headline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${song.artist} • ${song.formattedDuration}',
                          style: AppTypography.footnote,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textTertiary),
                          onPressed: () => SongOptionsBottomSheet.show(context, song),
                        ),
                        onTap: () {
                          playerController.playQueue(_currentSongs, initialIndex: index);
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 78, right: 20),
                        child: Divider(),
                      ),
                    ],
                  );
                },
                childCount: _currentSongs.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ],
      ),
    );
  }

  void _renamePlaylist() {
    final textController = TextEditingController(text: widget.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rename Playlist', style: AppTypography.title2),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: AppTypography.body,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            child: const Text('Save'),
            onPressed: () {
              final newName = textController.text.trim();
              if (newName.isNotEmpty && widget.playlistId != null) {
                ref.read(playlistsProvider.notifier).renamePlaylist(widget.playlistId!, newName);
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _deletePlaylist() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Playlist?', style: AppTypography.title2),
        content: Text('Are you sure you want to delete "${widget.title}"?', style: AppTypography.body),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Delete'),
            onPressed: () {
              if (widget.playlistId != null) {
                ref.read(playlistsProvider.notifier).deletePlaylist(widget.playlistId!);
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
