class PlaylistModel {
  final int id;
  final String name;
  final int songCount;
  final DateTime createdAt;

  const PlaylistModel({
    required this.id,
    required this.name,
    this.songCount = 0,
    required this.createdAt,
  });

  PlaylistModel copyWith({
    int? id,
    String? name,
    int? songCount,
    DateTime? createdAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      songCount: songCount ?? this.songCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
