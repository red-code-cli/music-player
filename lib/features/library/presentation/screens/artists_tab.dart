import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_music_app_bar.dart';
import '../controllers/library_controller.dart';
import '../../../player/presentation/controllers/player_controller.dart';

class ArtistsTabScreen extends ConsumerWidget {
  const ArtistsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppleMusicSliverAppBar(
            title: 'Artists',
          ),
          if (libraryState.artists.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No Artists Found', style: AppTypography.subhead),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final artist = libraryState.artists[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceElevated,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.accent,
                            size: 26,
                          ),
                        ),
                        title: Text(
                          artist.artist,
                          style: AppTypography.headline,
                        ),
                        subtitle: Text(
                          '${artist.numberOfTracks} Songs • ${artist.numberOfAlbums} Albums',
                          style: AppTypography.footnote,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                        onTap: () {
                          final allSongs = ref.read(libraryProvider).songs;
                          final artistSongs = allSongs.where((s) => s.artist == artist.artist).toList();
                          if (artistSongs.isNotEmpty) {
                            ref.read(playerControllerProvider).playQueue(artistSongs);
                          }
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 80, right: 20),
                        child: Divider(),
                      ),
                    ],
                  );
                },
                childCount: libraryState.artists.length,
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
