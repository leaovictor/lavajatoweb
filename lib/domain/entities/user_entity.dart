class UserEntity {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final bool isAdmin;

  UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.isAdmin = false,
  });
}
