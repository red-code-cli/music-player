import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/features/library/data/repositories/audio_query_repository.dart';
import 'package:music_player/features/library/domain/models/album_model.dart';
import 'package:music_player/features/library/domain/models/artist_model.dart';
import 'package:music_player/features/library/domain/models/folder_model.dart';
import 'package:music_player/features/library/domain/models/song_model.dart';

final audioQueryRepositoryProvider = Provider<AudioQueryRepository>((ref) {
  return AudioQueryRepository();
});

class LibraryState {
  final List<SongModel> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;
  final List<FolderModel> folders;
  final bool isLoading;
  final bool excludeShortSongs;
  final SongSortOption sortOption;
  final String? errorMessage;

  const LibraryState({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.folders = const [],
    this.isLoading = true,
    this.excludeShortSongs = true,
    this.sortOption = SongSortOption.titleAsc,
    this.errorMessage,
  });

  LibraryState copyWith({
    List<SongModel>? songs,
    List<AlbumModel>? albums,
    List<ArtistModel>? artists,
    List<FolderModel>? folders,
    bool? isLoading,
    bool? excludeShortSongs,
    SongSortOption? sortOption,
    String? errorMessage,
  }) {
    return LibraryState(
      songs: songs ?? this.songs,
      albums: albums ?? this.albums,
      artists: artists ?? this.artists,
      folders: folders ?? this.folders,
      isLoading: isLoading ?? this.isLoading,
      excludeShortSongs: excludeShortSongs ?? this.excludeShortSongs,
      sortOption: sortOption ?? this.sortOption,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final AudioQueryRepository _repo;

  LibraryNotifier(this._repo) : super(const LibraryState()) {
    scanLibrary();
  }

  Future<void> scanLibrary() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final songs = await _repo.fetchSongs(
        excludeShortSongs: state.excludeShortSongs,
        sortOption: state.sortOption,
      );
      final albums = await _repo.fetchAlbums();
      final artists = await _repo.fetchArtists();
      final folders = _repo.groupSongsByFolder(songs);

      state = state.copyWith(
        songs: songs,
        albums: albums,
        artists: artists,
        folders: folders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to scan storage: $e',
      );
    }
  }

  void setSortOption(SongSortOption option) {
    if (state.sortOption == option) return;
    state = state.copyWith(sortOption: option);
    scanLibrary();
  }

  void toggleExcludeShortSongs(bool value) {
    if (state.excludeShortSongs == value) return;
    state = state.copyWith(excludeShortSongs: value);
    scanLibrary();
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  final repo = ref.watch(audioQueryRepositoryProvider);
  return LibraryNotifier(repo);
});
