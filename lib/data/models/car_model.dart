import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/entities/car_entity.dart';

class CarModel extends CarEntity {
  CarModel({
    required String id,
    required String brand,
    required String model,
    required String licensePlate,
  }) : super(
          id: id,
          brand: brand,
          model: model,
          licensePlate: licensePlate,
        );

  factory CarModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CarModel(
      id: doc.id,
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      licensePlate: data['licensePlate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'licensePlate': licensePlate,
    };
  }
}
