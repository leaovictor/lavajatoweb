import 'package:lavajato/domain/entities/subscription_entity.dart';

class UserEntity {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final bool isAdmin;
  final SubscriptionEntity? subscription;

  UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.isAdmin = false,
    this.subscription,
  });
}
