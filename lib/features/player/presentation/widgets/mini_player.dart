import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/constants/app_colors.dart';
import 'package:music_player/core/constants/app_typography.dart';
import 'package:music_player/core/widgets/glass_container.dart';
import 'package:music_player/core/widgets/song_artwork_widget.dart';
import 'package:music_player/features/library/domain/models/song_model.dart';
import 'package:music_player/features/player/presentation/controllers/player_controller.dart';
import 'package:music_player/features/player/presentation/screens/full_player_screen.dart';

class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItemAsync = ref.watch(mediaItemStreamProvider);
    final playbackStateAsync = ref.watch(playbackStateStreamProvider);
    final playerController = ref.watch(playerControllerProvider);

    final mediaItem = mediaItemAsync.value;
    if (mediaItem == null) {
      return const SizedBox.shrink();
    }

    final isPlaying = playbackStateAsync.value?.playing ?? false;
    final songId = int.tryParse(mediaItem.id) ?? 0;

    final song = SongModel(
      id: songId,
      title: mediaItem.title,
      artist: mediaItem.artist ?? 'Unknown Artist',
      album: mediaItem.album ?? 'Unknown Album',
      duration: mediaItem.duration?.inMilliseconds ?? 0,
      filePath: mediaItem.extras?['filePath'] as String? ?? '',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: GestureDetector(
        onTap: () => FullPlayerScreen.open(context, song),
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
            FullPlayerScreen.open(context, song);
          }
        },
        child: GlassContainer(
          borderRadius: BorderRadius.circular(16),
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SongArtworkWidget(id: songId, size: 48, borderRadius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      song.artist,
                      style: AppTypography.footnote,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.textPrimary,
                  size: 32,
                ),
                onPressed: () => playerController.playPause(),
                splashRadius: 22,
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
                onPressed: () => playerController.skipNext(),
                splashRadius: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
