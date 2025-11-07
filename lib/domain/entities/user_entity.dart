import 'package:equatable/equatable.dart';
import 'package:lavajato/domain/entities/subscription_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final bool isAdmin;
  final SubscriptionEntity? subscription;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.isAdmin = false,
    this.subscription,
  });

  @override
  List<Object?> get props => [id, email, name, photoUrl, isAdmin, subscription];
}
