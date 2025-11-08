import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/data/models/user_model.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:lavajato/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  @override
  Future<int> getActiveClientCount() async {
    final result = await _firestore.collection('users').where('subscription.status', isEqualTo: 'active').get();
    return result.docs.length;
  }

  @override
  Future<UserEntity> getClient(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    return UserModel.fromFirestore(doc);
  }

  @override
  Stream<List<UserEntity>> getClients() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final userModel = UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      isAdmin: user.isAdmin,
      subscription: user.subscription,
    );
    await _firestore.collection('users').doc(user.id).update(userModel.toFirestore());
  }
}
