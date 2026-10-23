/// Pure domain object for a fashion creator.
class CreatorEntity {
  final String creatorId;
  final String name;
  final String profileImage;
  final String email;
  final String instagram;
  final String instagramUrl;

  const CreatorEntity({
    required this.creatorId,
    required this.name,
    required this.profileImage,
    required this.email,
    required this.instagram,
    required this.instagramUrl,
  });

  CreatorEntity copyWith({
    String? creatorId,
    String? name,
    String? profileImage,
    String? email,
    String? instagram,
    String? instagramUrl,
  }) =>
      CreatorEntity(
        creatorId:    creatorId    ?? this.creatorId,
        name:         name         ?? this.name,
        profileImage: profileImage ?? this.profileImage,
        email:        email        ?? this.email,
        instagram:    instagram    ?? this.instagram,
        instagramUrl: instagramUrl ?? this.instagramUrl,
      );
}
