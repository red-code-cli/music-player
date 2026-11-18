import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/apple_music_app_bar.dart';
import '../../../../core/widgets/song_artwork_widget.dart';
import '../../domain/models/album_model.dart';
import '../controllers/library_controller.dart';
import '../../../player/presentation/controllers/player_controller.dart';

class AlbumsTabScreen extends ConsumerWidget {
  const AlbumsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppleMusicSliverAppBar(
            title: 'Albums',
          ),
          if (libraryState.albums.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No Albums Found', style: AppTypography.subhead),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.76,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final album = libraryState.albums[index];
                    return GestureDetector(
                      onTap: () => _openAlbum(context, ref, album),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SongArtworkWidget(
                              id: album.id,
                              type: ArtworkType.ALBUM,
                              size: double.infinity,
                              borderRadius: 14,
                              placeholderIcon: Icons.album_rounded,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            album.album,
                            style: AppTypography.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            album.artist,
                            style: AppTypography.footnote,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: libraryState.albums.length,
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

  void _openAlbum(BuildContext context, WidgetRef ref, AlbumModel album) {
    final allSongs = ref.read(libraryProvider).songs;
    final albumSongs = allSongs.where((s) => s.album == album.album).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollCtrl) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  SongArtworkWidget(
                    id: album.id,
                    type: ArtworkType.ALBUM,
                    size: 60,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(album.album, style: AppTypography.title3),
                        Text(album.artist, style: AppTypography.footnote),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: albumSongs.length,
                itemBuilder: (context, i) {
                  final song = albumSongs[i];
                  return ListTile(
                    leading: Text('${i + 1}', style: AppTypography.caption1),
                    title: Text(song.title, style: AppTypography.headline),
                    subtitle: Text(song.formattedDuration, style: AppTypography.footnote),
                    onTap: () {
                      ref.read(playerControllerProvider).playQueue(albumSongs, initialIndex: i);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
