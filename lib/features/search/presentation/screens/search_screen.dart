import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_music_app_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppleMusicSliverAppBar(
            title: 'Search',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  // iOS styled search input
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: AppTypography.body,
                            decoration: const InputDecoration(
                              hintText: 'Artists, Songs, Lyrics and More',
                              hintStyle: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                            child: const Icon(
                              Icons.cancel_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Empty search guide
                  const Icon(
                    Icons.manage_search_rounded,
                    color: AppColors.textTertiary,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Search Your Local Music',
                    style: AppTypography.headline,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Quickly find tracks, artists, and albums in your device library.',
                    textAlign: TextAlign.center,
                    style: AppTypography.footnote,
                  ),
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
}
