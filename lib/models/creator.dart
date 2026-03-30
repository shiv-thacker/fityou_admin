import 'package:cloud_firestore/cloud_firestore.dart';

class Creator {
  final String creatorId;
  final String name;
  final String profileImage;
  final String email;
  final String instagram;
  final String instagramUrl;

  Creator({
    required this.creatorId,
    required this.name,
    required this.profileImage,
    required this.email,
    required this.instagram,
    required this.instagramUrl,
  });

  factory Creator.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Creator(
      creatorId: data['creatorId'] ?? doc.id,
      name: data['name'] ?? '',
      profileImage: data['profileImage'] ?? '',
      email: data['email'] ?? '',
      instagram: data['instagram'] ?? '',
      instagramUrl: data['instagramUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'creatorId': creatorId,
        'name': name,
        'profileImage': profileImage,
        'email': email,
        'instagram': instagram,
        'instagramUrl': instagramUrl,
      };

  Creator copyWith({
    String? creatorId,
    String? name,
    String? profileImage,
    String? email,
    String? instagram,
    String? instagramUrl,
  }) =>
      Creator(
        creatorId: creatorId ?? this.creatorId,
        name: name ?? this.name,
        profileImage: profileImage ?? this.profileImage,
        email: email ?? this.email,
        instagram: instagram ?? this.instagram,
        instagramUrl: instagramUrl ?? this.instagramUrl,
      );
}
