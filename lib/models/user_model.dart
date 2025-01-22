class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? profileImage; // This will now store base64 image string
  final bool isOnline;
  final DateTime lastSeen;
  final String? about;
  final String? phoneNumber;
  final List<String>? deviceTokens;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.profileImage,
    required this.isOnline,
    required this.lastSeen,
    this.about,
    this.phoneNumber,
    this.deviceTokens,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profileImage': profileImage,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'about': about,
      'phoneNumber': phoneNumber,
      'deviceTokens': deviceTokens,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      username: json['username'],
      email: json['email'],
      profileImage: json['profileImage'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: DateTime.parse(json['lastSeen']),
      about: json['about'],
      phoneNumber: json['phoneNumber'],
      deviceTokens: List<String>.from(json['deviceTokens'] ?? []),
    );
  }
}
