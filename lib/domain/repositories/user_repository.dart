import 'package:lavajato/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<int> getActiveClientCount();
  Stream<List<UserEntity>> getClients();
  Future<UserEntity> getClient(String id);
  Future<void> updateUser(UserEntity user);
}
