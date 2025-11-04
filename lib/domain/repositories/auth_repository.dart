import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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
}
