import 'package:cloud_firestore/cloud_firestore.dart';

class Outfit {
  final String outfitId;
  final List<String> imageUrl;
  final String creatorId;
  final String creatorName;
  final String creatorAvatar;
  final String size;
  final String skinTone;
  final String gender;
  final String category;
  final DateTime? createdAt;

  Outfit({
    required this.outfitId,
    required this.imageUrl,
    required this.creatorId,
    required this.creatorName,
    required this.creatorAvatar,
    required this.size,
    required this.skinTone,
    required this.gender,
    required this.category,
    this.createdAt,
  });

  factory Outfit.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Outfit(
      outfitId: doc.id,
      imageUrl: List<String>.from(data['imageUrl'] ?? []),
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      creatorAvatar: data['creatorAvatar'] ?? '',
      size: data['size'] ?? '',
      skinTone: data['skinTone'] ?? '',
      gender: data['gender'] ?? '',
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'imageUrl': imageUrl,
        'creatorId': creatorId,
        'creatorName': creatorName,
        'creatorAvatar': creatorAvatar,
        'size': size,
        'skinTone': skinTone,
        'gender': gender,
        'category': category,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}
