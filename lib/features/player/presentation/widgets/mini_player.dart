import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';

class MiniPlayerWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniPlayerWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          borderRadius: BorderRadius.circular(16),
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Artwork placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: AppColors.accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              // Song Info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'No Track Playing',
                      style: AppTypography.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Choose a song from Library',
                      style: AppTypography.footnote,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Controls
              IconButton(
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.textPrimary,
                  size: 30,
                ),
                onPressed: () {},
                splashRadius: 22,
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
                onPressed: () {},
                splashRadius: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
