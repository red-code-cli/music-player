import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/constants/app_colors.dart';
import 'package:music_player/core/constants/app_typography.dart';
import 'package:music_player/core/widgets/apple_music_app_bar.dart';
import 'package:music_player/features/library/presentation/controllers/library_controller.dart';
import 'package:music_player/features/player/presentation/controllers/player_controller.dart';
import 'package:music_player/features/player/presentation/widgets/equalizer_dialog.dart';
import 'package:music_player/features/player/presentation/widgets/sleep_timer_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);
    final libraryNotifier = ref.read(libraryProvider.notifier);
    final playerController = ref.read(playerControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppleMusicSliverAppBar(
            title: 'Settings',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PLAYBACK & AUDIO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSettingsGroup([
                    _buildSettingsTile(
                      icon: Icons.equalizer_rounded,
                      title: 'Equalizer & Bass Boost',
                      subtitle: 'Tune audio frequencies and sound stage',
                      onTap: () => EqualizerDialog.show(context),
                    ),
                    _buildSettingsTile(
                      icon: Icons.timer_rounded,
                      title: 'Sleep Timer',
                      subtitle: 'Stop playback automatically',
                      onTap: () => SleepTimerDialog.show(context, playerController),
                    ),
                    _buildSettingsTile(
                      icon: Icons.tune_rounded,
                      title: 'Gapless Playback',
                      subtitle: 'Continuous seamless audio',
                      trailing: Switch(
                        value: true,
                        activeThumbColor: AppColors.accent,
                        onChanged: (val) {},
                      ),
                      onTap: null,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  const Text(
                    'LIBRARY & SCANNING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSettingsGroup([
                    _buildSettingsTile(
                      icon: Icons.filter_alt_rounded,
                      title: 'Exclude Short Audio (< 30s)',
                      subtitle: 'Filter out ringtones & notification sounds',
                      trailing: Switch(
                        value: libraryState.excludeShortSongs,
                        activeThumbColor: AppColors.accent,
                        onChanged: (val) => libraryNotifier.toggleExcludeShortSongs(val),
                      ),
                      onTap: null,
                    ),
                    _buildSettingsTile(
                      icon: Icons.refresh_rounded,
                      title: 'Rescan Storage',
                      subtitle: 'Scan device for newly added music',
                      onTap: () {
                        libraryNotifier.scanLibrary();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Scanning storage for music...')),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  const Text(
                    'ABOUT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSettingsGroup([
                    _buildSettingsTile(
                      icon: Icons.security_rounded,
                      title: 'Offline & Privacy First',
                      subtitle: 'Zero internet permissions, 100% private',
                      onTap: null,
                    ),
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
                      subtitle: '1.0.0 (Release Build)',
                      onTap: null,
                    ),
                  ]),
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

  Widget _buildSettingsGroup(List<Widget> children) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent, size: 24),
      title: Text(title, style: AppTypography.headline),
      subtitle: Text(subtitle, style: AppTypography.footnote),
      trailing: trailing ??
          (onTap != null
              ? const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                )
              : null),
      onTap: onTap,
    );
  }
}
