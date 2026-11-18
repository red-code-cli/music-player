import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../controllers/player_controller.dart';

class QueueBottomSheet extends ConsumerWidget {
  const QueueBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const QueueBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueStreamProvider);
    final playbackStateAsync = ref.watch(playbackStateStreamProvider);
    final playerController = ref.watch(playerControllerProvider);

    final queue = queueAsync.value ?? [];
    final currentIndex = playbackStateAsync.value?.queueIndex ?? 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Playing Next', style: AppTypography.title3),
                  Text(
                    '${queue.length} Tracks',
                    style: AppTypography.footnote,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: queue.isEmpty
                  ? const Center(
                      child: Text(
                        'Queue is empty',
                        style: AppTypography.subhead,
                      ),
                    )
                  : ReorderableListView.builder(
                      scrollController: scrollController,
                      itemCount: queue.length,
                      onReorder: (oldIndex, newIndex) {
                        playerController.reorderQueue(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final item = queue[index];
                        final isCurrent = index == currentIndex;

                        return Dismissible(
                          key: Key('queue_${item.id}_$index'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: AppColors.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete_rounded, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            playerController.removeQueueItem(index);
                          },
                          child: ListTile(
                            key: Key('tile_${item.id}_$index'),
                            leading: isCurrent
                                ? const Icon(Icons.volume_up_rounded, color: AppColors.accent)
                                : const Icon(Icons.music_note_rounded, color: AppColors.textTertiary),
                            title: Text(
                              item.title,
                              style: isCurrent
                                  ? AppTypography.headline.copyWith(color: AppColors.accent)
                                  : AppTypography.headline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.artist ?? 'Unknown Artist',
                              style: AppTypography.footnote,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.drag_handle_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
