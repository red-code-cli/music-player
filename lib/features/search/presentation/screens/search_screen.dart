import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/constants/app_colors.dart';
import 'package:music_player/core/constants/app_typography.dart';
import 'package:music_player/core/widgets/apple_music_app_bar.dart';
import 'package:music_player/core/widgets/song_artwork_widget.dart';
import 'package:music_player/features/library/domain/models/song_model.dart';
import 'package:music_player/features/library/presentation/controllers/library_controller.dart';
import 'package:music_player/features/library/presentation/widgets/song_options_bottom_sheet.dart';
import 'package:music_player/features/player/presentation/controllers/player_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final playerController = ref.read(playerControllerProvider);

    final filteredSongs = _query.isEmpty
        ? <SongModel>[]
        : libraryState.songs.where((s) {
            final q = _query.toLowerCase();
            return s.title.toLowerCase().contains(q) ||
                s.artist.toLowerCase().contains(q) ||
                s.album.toLowerCase().contains(q);
          }).toList();

    final filteredAlbums = _query.isEmpty
        ? []
        : libraryState.albums.where((a) {
            final q = _query.toLowerCase();
            return a.album.toLowerCase().contains(q) || a.artist.toLowerCase().contains(q);
          }).toList();

    final filteredArtists = _query.isEmpty
        ? []
        : libraryState.artists.where((ar) {
            return ar.artist.toLowerCase().contains(_query.toLowerCase());
          }).toList();

    final hasResults = filteredSongs.isNotEmpty || filteredAlbums.isNotEmpty || filteredArtists.isNotEmpty;

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
              child: Container(
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
                        onChanged: (val) {
                          setState(() {
                            _query = val.trim();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Artists, Songs, Albums and More',
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                            _query = '';
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
            ),
          ),
          if (_query.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.manage_search_rounded,
                      color: AppColors.textTertiary,
                      size: 56,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Search Your Local Music',
                      style: AppTypography.headline,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Quickly find tracks, artists, and albums in your device library.',
                      textAlign: TextAlign.center,
                      style: AppTypography.footnote,
                    ),
                  ],
                ),
              ),
            )
          else if (!hasResults)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text('No results for "$_query"', style: AppTypography.headline),
                    const SizedBox(height: 4),
                    const Text('Check the spelling or try a different keyword', style: AppTypography.footnote),
                  ],
                ),
              ),
            )
          else ...[
            // Songs Section
            if (filteredSongs.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('Songs (${filteredSongs.length})', style: AppTypography.title3),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = filteredSongs[index];
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                          leading: SongArtworkWidget(id: song.id, size: 46, borderRadius: 8),
                          title: Text(
                            song.title,
                            style: AppTypography.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${song.artist} • ${song.formattedDuration}',
                            style: AppTypography.footnote,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textTertiary),
                            onPressed: () => SongOptionsBottomSheet.show(context, song),
                          ),
                          onTap: () {
                            playerController.playQueue(filteredSongs, initialIndex: index);
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 78, right: 20),
                          child: Divider(),
                        ),
                      ],
                    );
                  },
                  childCount: filteredSongs.length,
                ),
              ),
            ],

            // Albums Section
            if (filteredAlbums.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('Albums (${filteredAlbums.length})', style: AppTypography.title3),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final album = filteredAlbums[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      leading: const Icon(Icons.album_rounded, color: AppColors.accent, size: 36),
                      title: Text(album.album, style: AppTypography.headline),
                      subtitle: Text(album.artist, style: AppTypography.footnote),
                      onTap: () {
                        final albumSongs = libraryState.songs.where((s) => s.album == album.album).toList();
                        if (albumSongs.isNotEmpty) {
                          playerController.playQueue(albumSongs);
                        }
                      },
                    );
                  },
                  childCount: filteredAlbums.length,
                ),
              ),
            ],

            // Artists Section
            if (filteredArtists.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('Artists (${filteredArtists.length})', style: AppTypography.title3),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final artist = filteredArtists[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      leading: const Icon(Icons.person_rounded, color: AppColors.accent, size: 36),
                      title: Text(artist.artist, style: AppTypography.headline),
                      subtitle: Text('${artist.numberOfTracks} songs', style: AppTypography.footnote),
                      onTap: () {
                        final artistSongs = libraryState.songs.where((s) => s.artist == artist.artist).toList();
                        if (artistSongs.isNotEmpty) {
                          playerController.playQueue(artistSongs);
                        }
                      },
                    );
                  },
                  childCount: filteredArtists.length,
                ),
              ),
            ],

            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ],
      ),
    );
  }
}
