import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../domain/models/playlist_model.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'offline_music.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            song_id INTEGER PRIMARY KEY,
            added_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE playlists (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE playlist_songs (
            playlist_id INTEGER NOT NULL,
            song_id INTEGER NOT NULL,
            sort_order INTEGER NOT NULL,
            PRIMARY KEY (playlist_id, song_id),
            FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE play_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            song_id INTEGER NOT NULL,
            played_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE play_counts (
            song_id INTEGER PRIMARY KEY,
            count INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // --- FAVORITES ---
  Future<bool> isFavorite(int songId) async {
    final db = await database;
    final res = await db.query(
      'favorites',
      where: 'song_id = ?',
      whereArgs: [songId],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  Future<bool> toggleFavorite(int songId) async {
    final db = await database;
    final exists = await isFavorite(songId);
    if (exists) {
      await db.delete('favorites', where: 'song_id = ?', whereArgs: [songId]);
      return false;
    } else {
      await db.insert('favorites', {
        'song_id': songId,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    }
  }

  Future<List<int>> getFavoriteSongIds() async {
    final db = await database;
    final res = await db.query('favorites', orderBy: 'added_at DESC');
    return res.map((r) => r['song_id'] as int).toList();
  }

  // --- PLAYLISTS ---
  Future<int> createPlaylist(String name) async {
    final db = await database;
    return await db.insert('playlists', {
      'name': name.trim(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deletePlaylist(int playlistId) async {
    final db = await database;
    await db.delete('playlists', where: 'id = ?', whereArgs: [playlistId]);
    await db.delete('playlist_songs', where: 'playlist_id = ?', whereArgs: [playlistId]);
  }

  Future<void> renamePlaylist(int playlistId, String newName) async {
    final db = await database;
    await db.update(
      'playlists',
      {'name': newName.trim()},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT p.id, p.name, p.created_at, COUNT(ps.song_id) as song_count
      FROM playlists p
      LEFT JOIN playlist_songs ps ON p.id = ps.playlist_id
      GROUP BY p.id
      ORDER BY p.created_at DESC
    ''');

    return res.map((row) {
      return PlaylistModel(
        id: row['id'] as int,
        name: row['name'] as String,
        songCount: row['song_count'] as int? ?? 0,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );
    }).toList();
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    final db = await database;
    // Get max sort_order
    final maxOrderRes = await db.rawQuery('''
      SELECT MAX(sort_order) as max_order FROM playlist_songs WHERE playlist_id = ?
    ''', [playlistId]);
    final maxOrder = (maxOrderRes.first['max_order'] as int?) ?? 0;

    await db.insert(
      'playlist_songs',
      {
        'playlist_id': playlistId,
        'song_id': songId,
        'sort_order': maxOrder + 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    final db = await database;
    await db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
  }

  Future<List<int>> getPlaylistSongIds(int playlistId) async {
    final db = await database;
    final res = await db.query(
      'playlist_songs',
      columns: ['song_id'],
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'sort_order ASC',
    );
    return res.map((r) => r['song_id'] as int).toList();
  }

  // --- PLAY HISTORY & COUNTS ---
  Future<void> recordPlay(int songId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('play_history', {
      'song_id': songId,
      'played_at': now,
    });

    await db.rawInsert('''
      INSERT INTO play_counts (song_id, count)
      VALUES (?, 1)
      ON CONFLICT(song_id) DO UPDATE SET count = count + 1
    ''', [songId]);
  }

  Future<List<int>> getRecentlyPlayedSongIds({int limit = 30}) async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT song_id, MAX(played_at) as last_played
      FROM play_history
      GROUP BY song_id
      ORDER BY last_played DESC
      LIMIT ?
    ''', [limit]);
    return res.map((r) => r['song_id'] as int).toList();
  }

  Future<Map<int, int>> getPlayCounts() async {
    final db = await database;
    final res = await db.query('play_counts');
    final map = <int, int>{};
    for (final r in res) {
      map[r['song_id'] as int] = r['count'] as int;
    }
    return map;
  }
}
