import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../../library/presentation/screens/library_screen.dart';
import '../../playlists/presentation/screens/playlists_screen.dart';
import '../../search/presentation/screens/search_screen.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../player/presentation/widgets/mini_player.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    PlaylistsScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Screen content with IndexedStack
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Bottom Bar & Mini Player Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Mini Player
                MiniPlayerWidget(
                  onTap: () {
                    // Full player sheet trigger in Phase 5
                  },
                ),
                // Frosted Glass Bottom Navigation Bar
                GlassContainer(
                  blur: 24,
                  backgroundColor: AppColors.glassBackground,
                  border: const Border(
                    top: BorderSide(color: AppColors.glassBorder, width: 0.5),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            index: 0,
                            icon: Icons.play_circle_fill_rounded,
                            label: 'Listen Now',
                          ),
                          _buildNavItem(
                            index: 1,
                            icon: Icons.library_music_rounded,
                            label: 'Library',
                          ),
                          _buildNavItem(
                            index: 2,
                            icon: Icons.queue_music_rounded,
                            label: 'Playlists',
                          ),
                          _buildNavItem(
                            index: 3,
                            icon: Icons.search_rounded,
                            label: 'Search',
                          ),
                          _buildNavItem(
                            index: 4,
                            icon: Icons.settings_rounded,
                            label: 'Settings',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.accent : AppColors.textSecondary;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
