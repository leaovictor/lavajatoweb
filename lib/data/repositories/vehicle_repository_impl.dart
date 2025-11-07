import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/data/models/car_model.dart';
import 'package:lavajato/domain/entities/car_entity.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  VehicleRepositoryImpl(this._firestore, this._authRepository);

  @override
  Future<List<CarEntity>> getVehicles() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final snapshot = await _firestore
        .collection('users')
        .doc(user.id)
        .collection('cars')
        .get();
    return snapshot.docs.map((doc) => CarModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addVehicle(CarEntity car) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final carModel = CarModel(
      id: '', // Firestore will generate the ID
      make: car.make,
      model: car.model,
      licensePlate: car.licensePlate,
    );
    await _firestore
        .collection('users')
        .doc(user.id)
        .collection('cars')
        .add(carModel.toFirestore());
  }
}
