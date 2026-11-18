import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../../library/presentation/controllers/library_controller.dart';
import '../../library/presentation/screens/library_screen.dart';
import '../../playlists/presentation/screens/playlists_screen.dart';
import '../../search/presentation/screens/search_screen.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../player/presentation/widgets/mini_player.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    PlaylistsScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    final granted = await PermissionService.requestPermissions();
    if (granted) {
      ref.read(libraryProvider.notifier).scanLibrary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Persistent Tab Screens
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Bottom Bar & Floating Mini Player
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniPlayerWidget(),
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
