import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_player/core/constants/app_colors.dart';

class SongArtworkWidget extends StatelessWidget {
  final int id;
  final ArtworkType type;
  final double size;
  final double borderRadius;
  final IconData placeholderIcon;

  const SongArtworkWidget({
    super.key,
    required this.id,
    this.type = ArtworkType.AUDIO,
    this.size = 50.0,
    this.borderRadius = 8.0,
    this.placeholderIcon = Icons.music_note_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: QueryArtworkWidget(
        id: id,
        type: type,
        artworkWidth: size,
        artworkHeight: size,
        artworkFit: BoxFit.cover,
        artworkBorder: BorderRadius.circular(borderRadius),
        nullArtworkWidget: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            placeholderIcon,
            color: AppColors.textTertiary,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
