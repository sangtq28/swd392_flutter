class UserAuth {
  final int userId;
  final String email;
  final String token;
  final String role;

  UserAuth({
    required this.userId,
    required this.email,
    required this.token,
    required this.role,
  });

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      userId: json['userId'],
      email: json['email'],
      token: json['token'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'token': token,
      'role': role,
    };
  }
}
