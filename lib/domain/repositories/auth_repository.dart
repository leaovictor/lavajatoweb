import 'package:lavajato/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get user;
  UserEntity? get currentUser;
  Future<void> signOut();
}
