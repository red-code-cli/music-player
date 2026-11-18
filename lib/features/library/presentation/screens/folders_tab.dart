import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_music_app_bar.dart';
import '../controllers/library_controller.dart';
import '../../../player/presentation/controllers/player_controller.dart';

class FoldersTabScreen extends ConsumerWidget {
  const FoldersTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppleMusicSliverAppBar(
            title: 'Folders',
          ),
          if (libraryState.folders.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No Storage Folders Found', style: AppTypography.subhead),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final folder = libraryState.folders[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.folder_rounded,
                            color: AppColors.warning,
                            size: 26,
                          ),
                        ),
                        title: Text(
                          folder.name,
                          style: AppTypography.headline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${folder.songCount} Songs • ${folder.path}',
                          style: AppTypography.footnote,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                        onTap: () {
                          final allSongs = ref.read(libraryProvider).songs;
                          final folderSongs = allSongs.where((s) => s.filePath.startsWith(folder.path)).toList();
                          if (folderSongs.isNotEmpty) {
                            ref.read(playerControllerProvider).playQueue(folderSongs);
                          }
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 76, right: 20),
                        child: Divider(),
                      ),
                    ],
                  );
                },
                childCount: libraryState.folders.length,
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
