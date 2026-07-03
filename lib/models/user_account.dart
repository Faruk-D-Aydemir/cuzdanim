class UserAccount {
  UserAccount({
    required this.id,
    required this.email,
    required this.username,
  });

  final String id;
  final String email;
  final String username;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
  };

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
    );
  }

  factory UserAccount.fromFirestore(String id, Map<String, dynamic> data) {
    return UserAccount(
      id: id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
    );
  }
}
