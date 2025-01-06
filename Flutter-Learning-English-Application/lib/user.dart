class User {
  final String uid;
  final String username;
  final String fullName;
  final String email;
  final String avatar;

  User(
      {required this.uid,
      required this.username,
      required this.fullName,
      required this.email,
      required this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        uid: json['uid'],
        username: json['username'],
        fullName: json['fullName'],
        email: json['email'],
        avatar: json['avatar']);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'fullName': fullName,
      'email': email,
      'avatar': avatar,
    };
  }
}
