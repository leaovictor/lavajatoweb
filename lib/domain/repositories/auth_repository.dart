import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:lavajato/domain/entities/car_entity.dart';
import 'package:lavajato/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get user;
  Future<void> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<void> updateUserProfile(String userId, String name, String phone, String address);
  Future<void> addCar(String userId, CarEntity car);
  Stream<List<CarEntity>> getCars(String userId);
}
