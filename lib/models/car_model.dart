import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String id;
  final String brand;
  final String model;
  final String plate;
  final String color;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.plate,
    required this.color,
  });

  factory Car.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Car(
      id: doc.id,
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      plate: data['plate'] ?? '',
      color: data['color'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'plate': plate,
      'color': color,
    };
  }
}
