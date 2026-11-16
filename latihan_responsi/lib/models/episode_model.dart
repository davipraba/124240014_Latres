// Model data untuk Episode Rick & Morty (Nama episode, tanggal rilis/air_date, nomor episode)
class EpisodeModel {
  final int id;
  final String name;
  final String airDate;
  final String episode;
  final int characterCount;

  EpisodeModel({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episode,
    required this.characterCount,
  });

  // Mengubah data JSON dari endpoint /episode menjadi objek EpisodeModel
  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    int charCount = 0;
    if (json['characters'] != null && json['characters'] is List) {
      charCount = (json['characters'] as List).length;
    }

    return EpisodeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Episode Tanpa Judul',
      airDate: json['air_date']?.toString() ?? 'Tanggal Tidak Diketahui',
      episode: json['episode']?.toString() ?? '',
      characterCount: charCount,
    );
  }

  // Mengubah objek EpisodeModel menjadi format Map/JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'air_date': airDate,
      'episode': episode,
      'characterCount': characterCount,
    };
  }
}
