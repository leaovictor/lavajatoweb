import 'package:cloud_firestore/cloud_firestore.dart';

class Plan {
  final String id;
  final String name;
  final double price;
  final List<String> features;

  Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
  });

  factory Plan.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Plan(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      features: List<String>.from(data['features'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'features': features,
    };
  }
}
