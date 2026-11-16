// Model data untuk Karakter Rick & Morty
// Digunakan untuk menampung data dari REST API dan disimpan ke SharedPreferences (Favorit)
class CharacterModel {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String originName;
  final String locationName;
  final String image;
  final int episodeCount;

  CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.originName,
    required this.locationName,
    required this.image,
    required this.episodeCount,
  });

  // Mengubah data JSON yang diterima dari REST API Rick & Morty menjadi objek CharacterModel
  factory CharacterModel.fromApiJson(Map<String, dynamic> json) {
    // Mengambil nama origin (asal) dari objek nested JSON
    String origin = 'Unknown';
    if (json['origin'] != null && json['origin'] is Map) {
      origin = json['origin']['name']?.toString() ?? 'Unknown';
    }

    // Mengambil nama location (lokasi) dari objek nested JSON
    String location = 'Unknown';
    if (json['location'] != null && json['location'] is Map) {
      location = json['location']['name']?.toString() ?? 'Unknown';
    }

    // Menghitung jumlah episode yang diikuti oleh karakter ini
    int epCount = 0;
    if (json['episode'] != null && json['episode'] is List) {
      epCount = (json['episode'] as List).length;
    }

    return CharacterModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      status: json['status']?.toString() ?? 'Unknown',
      species: json['species']?.toString() ?? 'Unknown',
      type: json['type']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'Unknown',
      originName: origin,
      locationName: location,
      image: json['image']?.toString() ?? '',
      episodeCount: epCount,
    );
  }

  // Mengubah JSON dari SharedPreferences menjadi objek CharacterModel
  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Unknown',
      species: json['species']?.toString() ?? 'Unknown',
      type: json['type']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'Unknown',
      originName: json['originName']?.toString() ?? 'Unknown',
      locationName: json['locationName']?.toString() ?? 'Unknown',
      image: json['image']?.toString() ?? '',
      episodeCount: json['episodeCount'] is int
          ? json['episodeCount']
          : int.tryParse(json['episodeCount']?.toString() ?? '0') ?? 0,
    );
  }

  // Mengubah objek CharacterModel menjadi Map JSON (untuk disimpan ke SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'originName': originName,
      'locationName': locationName,
      'image': image,
      'episodeCount': episodeCount,
    };
  }
}
