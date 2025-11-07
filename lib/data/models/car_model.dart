import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/entities/car_entity.dart';

class CarModel extends CarEntity {
  const CarModel({
    required String id,
    required String make,
    required String model,
    required String licensePlate,
  }) : super(
          id: id,
          make: make,
          model: model,
          licensePlate: licensePlate,
        );

  factory CarModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CarModel(
      id: doc.id,
      make: data['make'],
      model: data['model'],
      licensePlate: data['licensePlate'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'make': make,
      'model': model,
      'licensePlate': licensePlate,
    };
  }
}
