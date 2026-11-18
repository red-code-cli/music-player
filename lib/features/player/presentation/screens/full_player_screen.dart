import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/song_artwork_widget.dart';
import '../../library/domain/models/song_model.dart';
import '../controllers/player_controller.dart';
import '../widgets/queue_bottom_sheet.dart';
import '../widgets/equalizer_dialog.dart';
import '../widgets/sleep_timer_dialog.dart';
import '../widgets/lyrics_view_sheet.dart';

class FullPlayerScreen extends ConsumerWidget {
  final SongModel song;

  const FullPlayerScreen({
    super.key,
    required this.song,
  });

  static void open(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (context) => FullPlayerScreen(song: song),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(playerControllerProvider);
    final playbackStateAsync = ref.watch(playbackStateStreamProvider);
    final positionAsync = ref.watch(playerPositionStreamProvider);
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.contains(song.id);

    final isPlaying = playbackStateAsync.value?.playing ?? false;
    final position = positionAsync.value ?? Duration.zero;
    final totalDuration = Duration(milliseconds: song.duration);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Dynamic Ambient Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.35),
                  AppColors.surface.withValues(alpha: 0.8),
                  AppColors.background,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 0.85],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Drag indicator & Dismiss Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 36, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        width: 38,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHover,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz_rounded, size: 28, color: AppColors.textSecondary),
                        onPressed: () {
                          // Options
                        },
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // Large Album Artwork
                  Center(
                    child: Container(
                      width: 290,
                      height: 290,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 30,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: SongArtworkWidget(
                        id: song.id,
                        size: 290,
                        borderRadius: 22,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Title, Artist and Heart
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 32,
                              child: song.title.length > 25
                                  ? Marquee(
                                      text: song.title,
                                      style: AppTypography.title2,
                                      scrollAxis: Axis.horizontal,
                                      blankSpace: 40.0,
                                      velocity: 30.0,
                                      pauseAfterRound: const Duration(seconds: 2),
                                    )
                                  : Text(
                                      song.title,
                                      style: AppTypography.title2,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              style: AppTypography.callout.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? AppColors.accent : AppColors.textSecondary,
                          size: 28,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(favoritesProvider.notifier).toggleFavorite(song.id);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Seek Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      trackHeight: 4,
                      activeTrackColor: AppColors.textPrimary,
                      inactiveTrackColor: AppColors.surfaceHover,
                      thumbColor: AppColors.textPrimary,
                    ),
                    child: Slider(
                      value: position.inMilliseconds.clamp(0, totalDuration.inMilliseconds).toDouble(),
                      max: totalDuration.inMilliseconds.toDouble() > 0 ? totalDuration.inMilliseconds.toDouble() : 1.0,
                      onChanged: (val) {
                        playerController.seek(Duration(milliseconds: val.toInt()));
                      },
                    ),
                  ),

                  // Elapsed & Remaining Time
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.formatDuration(position),
                          style: AppTypography.caption1,
                        ),
                        Text(
                          Formatters.formatDuration(totalDuration - position),
                          style: AppTypography.caption1,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Main Controls: Previous, Play/Pause, Next
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, size: 44, color: AppColors.textPrimary),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          playerController.skipPrevious();
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          playerController.playPause();
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.textPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 44,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 44, color: AppColors.textPrimary),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          playerController.skipNext();
                        },
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Bottom Action Shortcuts: Lyrics, Equalizer, Sleep Timer, Queue
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.lyrics_rounded, color: AppColors.textSecondary, size: 24),
                          onPressed: () => LyricsViewSheet.show(context, song, position),
                        ),
                        IconButton(
                          icon: const Icon(Icons.equalizer_rounded, color: AppColors.textSecondary, size: 24),
                          onPressed: () => EqualizerDialog.show(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.timer_rounded, color: AppColors.textSecondary, size: 24),
                          onPressed: () => SleepTimerDialog.show(context, playerController),
                        ),
                        IconButton(
                          icon: const Icon(Icons.queue_music_rounded, color: AppColors.textSecondary, size: 26),
                          onPressed: () => QueueBottomSheet.show(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
