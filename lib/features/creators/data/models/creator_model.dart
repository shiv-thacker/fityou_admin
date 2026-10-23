import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/creator_entity.dart';

/// Data-layer model: extends [CreatorEntity] with Firestore serialization.
class CreatorModel extends CreatorEntity {
  const CreatorModel({
    required super.creatorId,
    required super.name,
    required super.profileImage,
    required super.email,
    required super.instagram,
    required super.instagramUrl,
  });

  factory CreatorModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CreatorModel(
      creatorId:    (d['creatorId']    ?? doc.id).toString(),
      name:         (d['name']         ?? '').toString(),
      profileImage: (d['profileImage'] ?? '').toString(),
      email:        (d['email']        ?? '').toString(),
      instagram:    (d['instagram']    ?? '').toString(),
      instagramUrl: (d['instagramUrl'] ?? '').toString(),
    );
  }

  factory CreatorModel.fromEntity(CreatorEntity e) => CreatorModel(
        creatorId:    e.creatorId,
        name:         e.name,
        profileImage: e.profileImage,
        email:        e.email,
        instagram:    e.instagram,
        instagramUrl: e.instagramUrl,
      );

  Map<String, dynamic> toMap() => {
        'creatorId':    creatorId,
        'name':         name,
        'profileImage': profileImage,
        'email':        email,
        'instagram':    instagram,
        'instagramUrl': instagramUrl,
      };
}
