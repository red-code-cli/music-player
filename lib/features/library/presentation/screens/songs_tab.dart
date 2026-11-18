import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_music_app_bar.dart';
import '../../../../core/widgets/song_artwork_widget.dart';
import '../../data/repositories/audio_query_repository.dart';
import '../../domain/models/song_model.dart';
import '../controllers/library_controller.dart';
import '../widgets/song_options_bottom_sheet.dart';
import '../../../player/presentation/controllers/player_controller.dart';

class SongsTabScreen extends ConsumerWidget {
  const SongsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);
    final libraryNotifier = ref.read(libraryProvider.notifier);
    final playerController = ref.read(playerControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: () => libraryNotifier.scanLibrary(),
        child: CustomScrollView(
          slivers: [
            AppleMusicSliverAppBar(
              title: 'Songs',
              actions: [
                IconButton(
                  icon: const Icon(Icons.sort_rounded, color: AppColors.accent),
                  onPressed: () => _showSortSheet(context, libraryState.sortOption, libraryNotifier),
                ),
              ],
            ),
            if (libraryState.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            else if (libraryState.songs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.music_off_rounded, size: 54, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      const Text('No Songs Found', style: AppTypography.headline),
                      const SizedBox(height: 6),
                      const Text(
                        'Copy offline audio files (.mp3, .m4a, .flac) to your device.',
                        style: AppTypography.footnote,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.accent,
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Rescan Storage'),
                        onPressed: () => libraryNotifier.scanLibrary(),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Action Buttons: Play All & Shuffle
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
                            playerController.playQueue(libraryState.songs, initialIndex: 0);
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
                            final shuffled = List<SongModel>.from(libraryState.songs)..shuffle();
                            playerController.playQueue(shuffled, initialIndex: 0);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Song List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = libraryState.songs[index];
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
                            playerController.playQueue(libraryState.songs, initialIndex: index);
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 78, right: 20),
                          child: Divider(),
                        ),
                      ],
                    );
                  },
                  childCount: libraryState.songs.length,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context, SongSortOption current, LibraryNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('Sort Songs', style: AppTypography.title3),
            ),
            const Divider(),
            _sortTile(ctx, 'Title (A-Z)', SongSortOption.titleAsc, current, notifier),
            _sortTile(ctx, 'Title (Z-A)', SongSortOption.titleDesc, current, notifier),
            _sortTile(ctx, 'Artist (A-Z)', SongSortOption.artistAsc, current, notifier),
            _sortTile(ctx, 'Artist (Z-A)', SongSortOption.artistDesc, current, notifier),
            _sortTile(ctx, 'Recently Added', SongSortOption.dateAddedDesc, current, notifier),
            _sortTile(ctx, 'Duration (Longest)', SongSortOption.durationDesc, current, notifier),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sortTile(
    BuildContext context,
    String label,
    SongSortOption option,
    SongSortOption current,
    LibraryNotifier notifier,
  ) {
    final isSelected = option == current;
    return ListTile(
      title: Text(label, style: AppTypography.headline),
      trailing: isSelected ? const Icon(Icons.check_rounded, color: AppColors.accent) : null,
      onTap: () {
        notifier.setSortOption(option);
        Navigator.pop(context);
      },
    );
  }
}
