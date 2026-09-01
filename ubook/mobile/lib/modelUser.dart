class User {
  final String id;
  final String name;
  final String profileUrl;
  final String status;

  User({
    required this.id,
    required this.name,
    required this.profileUrl,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      profileUrl: json['profile_url'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_url': profileUrl,
      'status': status,
    };
  }
}
