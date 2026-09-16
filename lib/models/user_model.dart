class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;
  final String avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '1',
      name: json['name'] as String? ?? (json['username'] as String? ?? 'Alex Johnson'),
      email: json['email'] as String? ?? 'alex.johnson@example.com',
      token: json['token'] as String? ?? 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
      avatar: json['avatar'] as String? ??
          (json['image'] as String? ??
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'avatar': avatar,
    };
  }
}
