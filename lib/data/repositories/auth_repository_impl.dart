import 'package:firebase_auth/firebase_auth.dart';
import 'package:lavajato/data/models/user_model.dart';
import 'package:lavajato/data/services/auth_service.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:rxdart/rxdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepositoryImpl({
    AuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  @override
  Stream<UserEntity?> get user {
    return _authService.user.switchMap((firebaseUser) {
      if (firebaseUser == null) {
        return Stream.value(null);
      }
      return _firestoreService.getUser(firebaseUser.uid).map((snapshot) {
        if (snapshot.exists) {
          final userModel = UserModel.fromFirestore(snapshot);
          return userModel;
        }
        return UserEntity(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
        );
      });
    });
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }
}
