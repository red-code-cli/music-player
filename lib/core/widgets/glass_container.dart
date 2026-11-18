import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:music_player/core/constants/app_colors.dart';

/// Translucent frosted-glass container with backdrop blur
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.backgroundColor = AppColors.glassBackground,
    this.borderRadius,
    this.border,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: border ??
                Border.all(
                  color: AppColors.glassBorder,
                  width: 0.5,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
