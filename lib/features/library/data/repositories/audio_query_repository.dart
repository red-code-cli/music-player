import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart' as aq;
import 'package:music_player/features/library/domain/models/album_model.dart';
import 'package:music_player/features/library/domain/models/artist_model.dart';
import 'package:music_player/features/library/domain/models/folder_model.dart';
import 'package:music_player/features/library/domain/models/song_model.dart';
import 'package:music_player/features/playlists/data/database/app_database.dart';

enum SongSortOption {
  titleAsc,
  titleDesc,
  artistAsc,
  artistDesc,
  dateAddedDesc,
  durationDesc,
}

class AudioQueryRepository {
  final aq.OnAudioQuery _audioQuery;
  final AppDatabase _db;

  AudioQueryRepository({
    aq.OnAudioQuery? audioQuery,
    AppDatabase? database,
  })  : _audioQuery = audioQuery ?? aq.OnAudioQuery(),
        _db = database ?? AppDatabase.instance;

  /// Query all songs with duration filter & local database sync
  Future<List<SongModel>> fetchSongs({
    bool excludeShortSongs = true,
    int minDurationMs = 30000,
    SongSortOption sortOption = SongSortOption.titleAsc,
  }) async {
    final rawSongs = await _audioQuery.querySongs(
      sortType: aq.SongSortType.TITLE,
      orderType: aq.OrderType.ASC_OR_SMALLER,
      uriType: aq.UriType.EXTERNAL,
      ignoreCase: true,
    );

    final favIds = (await _db.getFavoriteSongIds()).toSet();
    final playCounts = await _db.getPlayCounts();

    final songs = <SongModel>[];

    for (final s in rawSongs) {
      final dur = s.duration ?? 0;
      if (excludeShortSongs && dur < minDurationMs) {
        continue;
      }

      songs.add(
        SongModel(
          id: s.id,
          title: s.title.isNotEmpty ? s.title : 'Unknown Title',
          artist: s.artist != null && s.artist != '<unknown>' ? s.artist! : 'Unknown Artist',
          album: s.album != null && s.album != '<unknown>' ? s.album! : 'Unknown Album',
          albumId: s.albumId,
          duration: dur,
          filePath: s.data,
          fileSize: s.size,
          dateAdded: s.dateAdded,
          isFavorite: favIds.contains(s.id),
          playCount: playCounts[s.id] ?? 0,
        ),
      );
    }

    return _sortSongs(songs, sortOption);
  }

  /// Query Albums
  Future<List<AlbumModel>> fetchAlbums() async {
    final rawAlbums = await _audioQuery.queryAlbums(
      sortType: aq.AlbumSortType.ALBUM,
      orderType: aq.OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
    );

    return rawAlbums
        .map((a) => AlbumModel(
              id: a.id,
              album: a.album,
              artist: a.artist ?? 'Unknown Artist',
              numOfSongs: a.numOfSongs,
            ))
        .toList();
  }

  /// Query Artists
  Future<List<ArtistModel>> fetchArtists() async {
    final rawArtists = await _audioQuery.queryArtists(
      sortType: aq.ArtistSortType.ARTIST,
      orderType: aq.OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
    );

    return rawArtists
        .map((ar) => ArtistModel(
              id: ar.id,
              artist: ar.artist,
              numberOfTracks: ar.numberOfTracks ?? 0,
              numberOfAlbums: ar.numberOfAlbums ?? 0,
            ))
        .toList();
  }

  /// Group songs by folder
  List<FolderModel> groupSongsByFolder(List<SongModel> songs) {
    final folderMap = <String, int>{};

    for (final song in songs) {
      if (song.filePath.isEmpty) continue;
      final file = File(song.filePath);
      final parentPath = file.parent.path;
      folderMap[parentPath] = (folderMap[parentPath] ?? 0) + 1;
    }

    return folderMap.entries.map((entry) {
      final parts = entry.key.split('/');
      final folderName = parts.isNotEmpty ? parts.last : entry.key;
      return FolderModel(
        path: entry.key,
        name: folderName,
        songCount: entry.value,
      );
    }).toList();
  }

  List<SongModel> _sortSongs(List<SongModel> songs, SongSortOption sortOption) {
    switch (sortOption) {
      case SongSortOption.titleAsc:
        songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SongSortOption.titleDesc:
        songs.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case SongSortOption.artistAsc:
        songs.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
        break;
      case SongSortOption.artistDesc:
        songs.sort((a, b) => b.artist.toLowerCase().compareTo(a.artist.toLowerCase()));
        break;
      case SongSortOption.dateAddedDesc:
        songs.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
        break;
      case SongSortOption.durationDesc:
        songs.sort((a, b) => b.duration.compareTo(a.duration));
        break;
    }
    return songs;
  }
}
