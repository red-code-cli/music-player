import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/features/library/domain/models/song_model.dart';
import 'package:music_player/features/playlists/data/database/app_database.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MusicAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.offline.musicplayer.playback',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationChannelDescription: 'Control offline music playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidShowNotificationBadge: true,
    ),
  );
}

class MusicAudioHandler extends BaseAudioHandler with QueueAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final AppDatabase _db = AppDatabase.instance;

  // Active playlist and original order
  List<SongModel> _currentSongList = [];
  int _currentIndex = -1;

  // Sleep Timer
  Timer? _sleepTimer;
  DateTime? _sleepTimerEndTime;

  MusicAudioHandler() {
    _initAudioStreams();
  }

  AudioPlayer get player => _player;
  DateTime? get sleepTimerEndTime => _sleepTimerEndTime;

  void _initAudioStreams() {
    // 1. Broadcast playback state
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      final processingState = _player.processingState;

      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
            MediaAction.setRepeatMode,
            MediaAction.setShuffleMode,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: _currentIndex,
        ),
      );
    });

    // 2. Handle song completion to play next song
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  /// Load a queue of songs and start playing from index
  Future<void> loadQueue(List<SongModel> songs, {int initialIndex = 0}) async {
    if (songs.isEmpty) return;
    _currentSongList = List.from(songs);
    _currentIndex = initialIndex.clamp(0, songs.length - 1);

    final mediaItems = _currentSongList.map((s) {
      return MediaItem(
        id: s.id.toString(),
        title: s.title,
        artist: s.artist,
        album: s.album,
        duration: Duration(milliseconds: s.duration),
        artUri: Uri.parse('content://media/external/audio/media/${s.id}/albumart'),
        extras: {'filePath': s.filePath},
      );
    }).toList();

    queue.add(mediaItems);
    await _playCurrentIndex();
  }

  Future<void> _playCurrentIndex() async {
    if (_currentIndex < 0 || _currentIndex >= _currentSongList.length) return;

    final song = _currentSongList[_currentIndex];
    mediaItem.add(
      MediaItem(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: Duration(milliseconds: song.duration),
        artUri: Uri.parse('content://media/external/audio/media/${song.id}/albumart'),
        extras: {'filePath': song.filePath},
      ),
    );

    try {
      await _player.setFilePath(song.filePath);
      await _player.play();
      unawaited(_db.recordPlay(song.id));
    } catch (e) {
      if (_currentSongList.length > 1) {
        skipToNext();
      }
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_currentSongList.isEmpty) return;

    if (_currentIndex + 1 < _currentSongList.length) {
      _currentIndex++;
      await _playCurrentIndex();
    } else if (_player.loopMode == LoopMode.all) {
      _currentIndex = 0;
      await _playCurrentIndex();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentSongList.isEmpty) return;

    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      _currentIndex--;
      await _playCurrentIndex();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      default:
        await _player.setLoopMode(LoopMode.off);
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode != AudioServiceShuffleMode.none;
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  // Play next or add to queue
  void playNext(SongModel song) {
    if (_currentSongList.isEmpty) {
      loadQueue([song]);
      return;
    }
    _currentSongList.insert(_currentIndex + 1, song);
    final currentQueue = queue.value;
    final item = MediaItem(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: Duration(milliseconds: song.duration),
      artUri: Uri.parse('content://media/external/audio/media/${song.id}/albumart'),
      extras: {'filePath': song.filePath},
    );
    currentQueue.insert(_currentIndex + 1, item);
    queue.add(List.from(currentQueue));
  }

  void addToQueue(SongModel song) {
    if (_currentSongList.isEmpty) {
      loadQueue([song]);
      return;
    }
    _currentSongList.add(song);
    final currentQueue = queue.value;
    final item = MediaItem(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: Duration(milliseconds: song.duration),
      artUri: Uri.parse('content://media/external/audio/media/${song.id}/albumart'),
      extras: {'filePath': song.filePath},
    );
    currentQueue.add(item);
    queue.add(List.from(currentQueue));
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _currentSongList.removeAt(oldIndex);
    _currentSongList.insert(newIndex, item);

    final queueItems = List<MediaItem>.from(queue.value);
    final qItem = queueItems.removeAt(oldIndex);
    queueItems.insert(newIndex, qItem);
    queue.add(queueItems);

    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
  }

  void removeQueueItemAtIndex(int index) {
    if (index < 0 || index >= _currentSongList.length) return;
    _currentSongList.removeAt(index);
    final queueItems = List<MediaItem>.from(queue.value);
    queueItems.removeAt(index);
    queue.add(queueItems);

    if (index < _currentIndex) {
      _currentIndex--;
    }
  }

  // Sleep Timer
  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimerEndTime = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, () async {
      await pause();
      _sleepTimerEndTime = null;
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerEndTime = null;
  }
}
