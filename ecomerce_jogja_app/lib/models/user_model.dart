class User {
  final String userId;
  final String? username;
  final String? namaLengkap;
  final String? email;
  final String? noTelepon;
  final String? alamat;
  final String token;

  User({
    required this.userId,
    this.username,
    this.namaLengkap,
    this.email,
    this.noTelepon,
    this.alamat,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      username: json['username'],
      namaLengkap: json['nama_lengkap'],
      email: json['email'],
      noTelepon: json['no_telepon'],
      alamat: json['alamat'],
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'token': token,
    };
  }

  User copyWith({
    String? userId,
    String? username,
    String? namaLengkap,
    String? email,
    String? noTelepon,
    String? alamat,
    String? token,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      noTelepon: noTelepon ?? this.noTelepon,
      alamat: alamat ?? this.alamat,
      token: token ?? this.token,
    );
  }
}
