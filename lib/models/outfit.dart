import 'package:cloud_firestore/cloud_firestore.dart';

/// Named URL for a piece of the outfit (e.g. label "T-shirt", url "https://…").
class OutfitLink {
  final String label;
  final String url;
  /// Free-form (e.g. "29.99" or "$45") — stored as string for currencies/symbols.
  final String price;

  const OutfitLink({
    required this.label,
    required this.url,
    this.price = '',
  });

  Map<String, dynamic> toMap() => {
        'label': label,
        'url': url,
        'price': price,
      };

  factory OutfitLink.fromMap(dynamic raw) {
    if (raw is! Map) {
      return const OutfitLink(label: '', url: '');
    }
    final m = Map<String, dynamic>.from(raw);
    return OutfitLink(
      label: (m['label'] ?? m['name'] ?? '').toString(),
      url: (m['url'] ?? '').toString(),
      price: (m['price'] ?? '').toString(),
    );
  }
}

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
  final List<String> tags;
  final List<OutfitLink> outfitLinks;
  final String description;
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
    this.tags = const [],
    this.outfitLinks = const [],
    this.description = '',
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
      tags: _parseStringList(data['tags']),
      outfitLinks: _parseOutfitLinks(data['outfitLinks']),
      description: (data['description'] ?? '').toString(),
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
        'tags': tags,
        'outfitLinks': outfitLinks.map((e) => e.toMap()).toList(),
        'description': description,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}

List<String> _parseStringList(dynamic value) {
  if (value is! List) return [];
  return value
      .map((e) => e?.toString() ?? '')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

List<OutfitLink> _parseOutfitLinks(dynamic value) {
  if (value is! List) return [];
  return value.map(OutfitLink.fromMap).toList();
}
