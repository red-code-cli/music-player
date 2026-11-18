import 'package:flutter/material.dart';
import 'package:music_player/core/constants/app_colors.dart';
import 'package:music_player/core/constants/app_typography.dart';

class AppleMusicSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? trailing;

  const AppleMusicSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 110.0,
      backgroundColor: AppColors.background.withValues(alpha: 0.85),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(
          start: 20,
          bottom: 12,
        ),
        title: Text(
          title,
          style: AppTypography.title1,
        ),
      ),
    );
  }
}
