class User {
  final int? id;
  final String? firebaseUid;
  final String username;
  final String email;
  final String password;
  final String createdAt;

  User({
    this.id,
    this.firebaseUid,
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  // Convert User object to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'username': username,
      'email': email,
      'password': password,
      'created_at': createdAt,
    };
  }

  // Create User object from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firebaseUid: map['firebase_uid'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      createdAt: map['created_at'],
    );
  }

  // Copy with method for updating user
  User copyWith({
    int? id,
    String? firebaseUid,
    String? username,
    String? email,
    String? password,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
