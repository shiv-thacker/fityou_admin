/// Pure domain object for a named shop link on an outfit.
class OutfitLinkEntity {
  final String label;
  final String url;
  /// Free-form price string (e.g. "29.99" or "$45").
  final String price;

  const OutfitLinkEntity({
    required this.label,
    required this.url,
    this.price = '',
  });
}

/// Pure domain object for a fashion outfit.
class OutfitEntity {
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
  final List<OutfitLinkEntity> outfitLinks;
  final String description;
  final DateTime? createdAt;

  const OutfitEntity({
    required this.outfitId,
    required this.imageUrl,
    required this.creatorId,
    required this.creatorName,
    required this.creatorAvatar,
    required this.size,
    required this.skinTone,
    required this.gender,
    required this.category,
    this.tags        = const [],
    this.outfitLinks = const [],
    this.description = '',
    this.createdAt,
  });
}
