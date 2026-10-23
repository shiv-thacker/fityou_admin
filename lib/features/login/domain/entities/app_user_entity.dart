/// Pure domain object representing the signed-in admin user.
/// No Firebase or platform dependencies.
class AppUserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isAdmin;

  const AppUserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isAdmin = false,
  });
}
