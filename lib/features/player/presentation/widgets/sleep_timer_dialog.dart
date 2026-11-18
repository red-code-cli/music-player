import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../controllers/player_controller.dart';

class SleepTimerDialog extends StatelessWidget {
  final PlayerController controller;

  const SleepTimerDialog({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, PlayerController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SleepTimerDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final durations = [
      ('15 Minutes', const Duration(minutes: 15)),
      ('30 Minutes', const Duration(minutes: 30)),
      ('45 Minutes', const Duration(minutes: 45)),
      ('60 Minutes', const Duration(minutes: 60)),
      ('90 Minutes', const Duration(minutes: 90)),
    ];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceHover,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.timer_rounded, color: AppColors.accent, size: 28),
                SizedBox(width: 10),
                Text('Sleep Timer', style: AppTypography.title2),
              ],
            ),
          ),
          const Divider(),
          ...durations.map((d) {
            return ListTile(
              title: Text(d.$1, style: AppTypography.headline),
              onTap: () {
                controller.startSleepTimer(d.$2);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sleep timer set for ${d.$1}')),
                );
              },
            );
          }),
          ListTile(
            leading: const Icon(Icons.cancel_rounded, color: AppColors.error),
            title: const Text('Turn Off Timer', style: TextStyle(color: AppColors.error)),
            onTap: () {
              controller.cancelSleepTimer();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sleep timer cancelled')),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
