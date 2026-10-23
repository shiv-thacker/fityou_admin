import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/outfit_entity.dart';

/// Data-layer model with Firestore serialization.
class OutfitLinkModel extends OutfitLinkEntity {
  const OutfitLinkModel({
    required super.label,
    required super.url,
    super.price,
  });

  factory OutfitLinkModel.fromMap(dynamic raw) {
    if (raw is! Map) return const OutfitLinkModel(label: '', url: '');
    final m = Map<String, dynamic>.from(raw);
    return OutfitLinkModel(
      label: (m['label'] ?? m['name'] ?? '').toString(),
      url:   (m['url']   ?? '').toString(),
      price: (m['price'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'url':   url,
        'price': price,
      };
}

class OutfitModel extends OutfitEntity {
  const OutfitModel({
    required super.outfitId,
    required super.imageUrl,
    required super.creatorId,
    required super.creatorName,
    required super.creatorAvatar,
    required super.size,
    required super.skinTone,
    required super.gender,
    required super.category,
    super.tags,
    super.outfitLinks,
    super.description,
    super.createdAt,
  });

  factory OutfitModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OutfitModel(
      outfitId:      doc.id,
      imageUrl:      List<String>.from(d['imageUrl'] ?? []),
      creatorId:     (d['creatorId']     ?? '').toString(),
      creatorName:   (d['creatorName']   ?? '').toString(),
      creatorAvatar: (d['creatorAvatar'] ?? '').toString(),
      size:          (d['size']          ?? '').toString(),
      skinTone:      (d['skinTone']      ?? '').toString(),
      gender:        (d['gender']        ?? '').toString(),
      category:      (d['category']      ?? '').toString(),
      tags:          _parseStringList(d['tags']),
      outfitLinks:   _parseOutfitLinks(d['outfitLinks']),
      description:   (d['description']   ?? '').toString(),
      createdAt:     (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory OutfitModel.fromEntity(OutfitEntity e) => OutfitModel(
        outfitId:      e.outfitId,
        imageUrl:      e.imageUrl,
        creatorId:     e.creatorId,
        creatorName:   e.creatorName,
        creatorAvatar: e.creatorAvatar,
        size:          e.size,
        skinTone:      e.skinTone,
        gender:        e.gender,
        category:      e.category,
        tags:          e.tags,
        outfitLinks:   e.outfitLinks,
        description:   e.description,
        createdAt:     e.createdAt,
      );

  Map<String, dynamic> toMap({bool preserveCreatedAt = false}) => {
        'imageUrl':      imageUrl,
        'creatorId':     creatorId,
        'creatorName':   creatorName,
        'creatorAvatar': creatorAvatar,
        'size':          size,
        'skinTone':      skinTone,
        'gender':        gender,
        'category':      category,
        'tags':          tags,
        'outfitLinks':
            outfitLinks.map((l) => (l as OutfitLinkModel).toMap()).toList(),
        'description': description,
        if (!preserveCreatedAt)
          'createdAt': createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
      };

  /// toMap for updates — never overwrites createdAt.
  Map<String, dynamic> toUpdateMap() {
    final m = toMap(preserveCreatedAt: true);
    m.remove('createdAt');
    return m;
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

List<String> _parseStringList(dynamic value) {
  if (value is! List) return [];
  return value
      .map((e) => e?.toString() ?? '')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

List<OutfitLinkEntity> _parseOutfitLinks(dynamic value) {
  if (value is! List) return [];
  return value.map(OutfitLinkModel.fromMap).toList();
}
