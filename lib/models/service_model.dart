import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String name;
  final String description;
  final num price;
  final int duration;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
  });

  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? 0,
      duration: data['duration'] ?? 60,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
    };
  }
}
