import '../../../../core/utils/formatters.dart';

class SongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int? albumId;
  final int duration; // in milliseconds
  final String filePath;
  final int fileSize; // in bytes
  final int? dateAdded;
  final bool isFavorite;
  final int playCount;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumId,
    required this.duration,
    required this.filePath,
    this.fileSize = 0,
    this.dateAdded,
    this.isFavorite = false,
    this.playCount = 0,
  });

  SongModel copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    int? albumId,
    int? duration,
    String? filePath,
    int? fileSize,
    int? dateAdded,
    bool? isFavorite,
    int? playCount,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      dateAdded: dateAdded ?? this.dateAdded,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
    );
  }

  String get formattedDuration => Formatters.formatDuration(Duration(milliseconds: duration));
  String get formattedFileSize => Formatters.formatFileSize(fileSize);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'albumId': albumId,
      'duration': duration,
      'filePath': filePath,
      'fileSize': fileSize,
      'dateAdded': dateAdded,
      'isFavorite': isFavorite ? 1 : 0,
      'playCount': playCount,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] as int,
      title: map['title'] as String? ?? 'Unknown Title',
      artist: map['artist'] as String? ?? 'Unknown Artist',
      album: map['album'] as String? ?? 'Unknown Album',
      albumId: map['albumId'] as int?,
      duration: map['duration'] as int? ?? 0,
      filePath: map['filePath'] as String? ?? '',
      fileSize: map['fileSize'] as int? ?? 0,
      dateAdded: map['dateAdded'] as int?,
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      playCount: map['playCount'] as int? ?? 0,
    );
  }
}
