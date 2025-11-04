import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:lavajato/data/models/car_model.dart';
import 'package:lavajato/data/models/user_model.dart';
import 'package:lavajato/data/services/auth_service.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:lavajato/domain/entities/car_entity.dart';
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
        // Fallback to auth data if firestore data is missing
        return UserEntity(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
        );
      });
    });
  }

  @override
  Future<void> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(email, password);
      if (userCredential.user != null) {
        final newUser = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
        );
        await _firestoreService.setUser(newUser);
      }
    } catch (e) {
      // Handle exceptions from auth or firestore
      rethrow;
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) {
    return _authService.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }

  @override
  Future<void> updateUserProfile(String userId, String name, String phone, String address) {
    return _firestoreService.updateUserProfile(userId, {
      'name': name,
      'phone': phone,
      'address': address,
    });
  }

  @override
  Future<void> addCar(String userId, CarEntity car) {
    final carModel = CarModel(
      id: car.id,
      brand: car.brand,
      model: car.model,
      licensePlate: car.licensePlate,
    );
    return _firestoreService.addCar(userId, carModel);
  }

  @override
  Stream<List<CarEntity>> getCars(String userId) {
    return _firestoreService.getCars(userId).map((snapshot) {
      return snapshot.docs.map((doc) => CarModel.fromFirestore(doc)).toList();
    });
  }
}
