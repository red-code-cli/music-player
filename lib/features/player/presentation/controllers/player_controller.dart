import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/core/services/audio_handler.dart';
import 'package:music_player/features/library/domain/models/song_model.dart';
import 'package:music_player/features/playlists/data/database/app_database.dart';

// 1. AudioHandler Global Provider
final audioHandlerProvider = Provider<MusicAudioHandler>((ref) {
  throw UnimplementedError('AudioHandler must be initialized before runApp');
});

// 2. Playback State Provider
final playbackStateStreamProvider = StreamProvider<PlaybackState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState;
});

// 3. Current MediaItem Stream Provider
final mediaItemStreamProvider = StreamProvider<MediaItem?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem;
});

// 4. Position Stream Provider
final playerPositionStreamProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.positionStream;
});

// 5. Queue Stream Provider
final queueStreamProvider = StreamProvider<List<MediaItem>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.queue;
});

// 6. Favorites Provider
class FavoritesNotifier extends StateNotifier<Set<int>> {
  final AppDatabase _db;

  FavoritesNotifier(this._db) : super({}) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final ids = await _db.getFavoriteSongIds();
    state = ids.toSet();
  }

  Future<void> toggleFavorite(int songId) async {
    final isFav = await _db.toggleFavorite(songId);
    if (isFav) {
      state = {...state, songId};
    } else {
      state = state.where((id) => id != songId).toSet();
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier(AppDatabase.instance);
});

// 7. Player Controller helper methods
class PlayerController {
  final MusicAudioHandler _handler;

  PlayerController(this._handler);

  void playQueue(List<SongModel> songs, {int initialIndex = 0}) {
    _handler.loadQueue(songs, initialIndex: initialIndex);
  }

  void playPause() {
    if (_handler.player.playing) {
      _handler.pause();
    } else {
      _handler.play();
    }
  }

  void skipNext() => _handler.skipToNext();
  void skipPrevious() => _handler.skipToPrevious();
  void seek(Duration position) => _handler.seek(position);

  void toggleShuffle() {
    final current = _handler.player.shuffleModeEnabled;
    _handler.setShuffleMode(current ? AudioServiceShuffleMode.none : AudioServiceShuffleMode.all);
  }

  void toggleRepeat() {
    final current = _handler.player.loopMode;
    switch (current) {
      case LoopMode.off:
        _handler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
      case LoopMode.all:
        _handler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case LoopMode.one:
        _handler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
    }
  }

  void playNext(SongModel song) => _handler.playNext(song);
  void addToQueue(SongModel song) => _handler.addToQueue(song);
  void reorderQueue(int oldIndex, int newIndex) => _handler.reorderQueue(oldIndex, newIndex);
  void removeQueueItem(int index) => _handler.removeQueueItemAtIndex(index);

  void setSpeed(double speed) => _handler.setSpeed(speed);
  void startSleepTimer(Duration duration) => _handler.startSleepTimer(duration);
  void cancelSleepTimer() => _handler.cancelSleepTimer();
}

final playerControllerProvider = Provider<PlayerController>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return PlayerController(handler);
});
