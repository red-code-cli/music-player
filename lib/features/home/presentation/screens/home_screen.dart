import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/constants/app_colors.dart';
import 'package:music_player/core/constants/app_typography.dart';
import 'package:music_player/core/widgets/apple_music_app_bar.dart';
import 'package:music_player/core/widgets/song_artwork_widget.dart';
import 'package:music_player/features/library/domain/models/song_model.dart';
import 'package:music_player/features/library/presentation/controllers/library_controller.dart';
import 'package:music_player/features/player/presentation/controllers/player_controller.dart';
import 'package:music_player/features/playlists/data/database/app_database.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);
    final playerController = ref.read(playerControllerProvider);

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
                  // Hero Offline Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.35),
                          AppColors.surface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OFFLINE MUSIC HUB',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your Local Library',
                          style: AppTypography.title2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${libraryState.songs.length} offline songs available on device.',
                          style: AppTypography.subhead,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.shuffle_rounded, size: 20),
                              label: const Text('Shuffle All'),
                              onPressed: libraryState.songs.isNotEmpty
                                  ? () {
                                      final shuffled = List<SongModel>.from(libraryState.songs)..shuffle();
                                      playerController.playQueue(shuffled);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Quick Picks Header
                  const Text('Quick Picks', style: AppTypography.title3),
                  const SizedBox(height: 12),

                  if (libraryState.songs.isEmpty)
                    Container(
                      height: 140,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_music_rounded, color: AppColors.textSecondary, size: 38),
                          SizedBox(height: 8),
                          Text('No songs loaded yet', style: AppTypography.callout),
                          SizedBox(height: 4),
                          Text('Scan storage from Library or Settings', style: AppTypography.footnote),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 210,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: libraryState.songs.take(10).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, i) {
                          final song = libraryState.songs[i];
                          return GestureDetector(
                            onTap: () {
                              playerController.playQueue(libraryState.songs, initialIndex: i);
                            },
                            child: SizedBox(
                              width: 130,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SongArtworkWidget(id: song.id, size: 130, borderRadius: 14),
                                  const SizedBox(height: 8),
                                  Text(
                                    song.title,
                                    style: AppTypography.headline.copyWith(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    song.artist,
                                    style: AppTypography.caption1,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Recently Played
                  const Text('Recently Played', style: AppTypography.title3),
                  const SizedBox(height: 12),

                  FutureBuilder<List<int>>(
                    future: AppDatabase.instance.getRecentlyPlayedSongIds(limit: 10),
                    builder: (context, snapshot) {
                      final ids = snapshot.data ?? [];
                      final songMap = {for (final s in libraryState.songs) s.id: s};
                      final recentSongs = ids.where((id) => songMap.containsKey(id)).map((id) => songMap[id]!).toList();

                      if (recentSongs.isEmpty) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_rounded, color: AppColors.textSecondary, size: 32),
                              SizedBox(height: 6),
                              Text('No recently played songs yet', style: AppTypography.callout),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: recentSongs.map((song) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: SongArtworkWidget(id: song.id, size: 44, borderRadius: 8),
                            title: Text(song.title, style: AppTypography.headline, maxLines: 1),
                            subtitle: Text(song.artist, style: AppTypography.footnote, maxLines: 1),
                            trailing: const Icon(Icons.play_circle_outline_rounded, color: AppColors.accent),
                            onTap: () {
                              playerController.playQueue(recentSongs, initialIndex: recentSongs.indexOf(song));
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
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
}
