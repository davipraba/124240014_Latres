// Model data untuk akun pengguna yang disimpan ke Local Database (SQLite)
class UserModel {
  final int? id;
  final String username;
  final String password;

  UserModel({
    this.id,
    required this.username,
    required this.password,
  });

  // Mengubah objek UserModel menjadi bentuk Map (untuk disimpan ke tabel database SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  // Mengubah data Map hasil query database SQLite kembali menjadi objek UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }
}
