import 'package:cloud_firestore/cloud_firestore.dart';

class Plan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String stripePriceId;

  Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stripePriceId,
  });

  factory Plan.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Plan(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      stripePriceId: data['stripePriceId'] ?? '',
    );
  }
}
