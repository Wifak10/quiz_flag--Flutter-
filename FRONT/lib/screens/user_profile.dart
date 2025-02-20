class UserProfile {
  final int id;
  final String username;
  final String email;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }
}