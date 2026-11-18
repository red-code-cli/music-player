import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/features/playlists/data/database/app_database.dart';
import 'package:music_player/features/playlists/domain/models/playlist_model.dart';
import 'package:music_player/features/library/domain/models/song_model.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

class PlaylistsNotifier extends StateNotifier<List<PlaylistModel>> {
  final AppDatabase _db;

  PlaylistsNotifier(this._db) : super([]) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    final list = await _db.getPlaylists();
    state = list;
  }

  Future<int> createPlaylist(String name) async {
    final id = await _db.createPlaylist(name);
    await loadPlaylists();
    return id;
  }

  Future<void> deletePlaylist(int id) async {
    await _db.deletePlaylist(id);
    await loadPlaylists();
  }

  Future<void> renamePlaylist(int id, String newName) async {
    await _db.renamePlaylist(id, newName);
    await loadPlaylists();
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    await _db.addSongToPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await _db.removeSongFromPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<List<SongModel>> getPlaylistSongs(int playlistId, List<SongModel> allSongs) async {
    final songIds = await _db.getPlaylistSongIds(playlistId);
    final songMap = {for (final s in allSongs) s.id: s};
    final result = <SongModel>[];
    for (final id in songIds) {
      if (songMap.containsKey(id)) {
        result.add(songMap[id]!);
      }
    }
    return result;
  }
}

final playlistsProvider = StateNotifierProvider<PlaylistsNotifier, List<PlaylistModel>>((ref) {
  final db = ref.watch(databaseProvider);
  return PlaylistsNotifier(db);
});
