import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  ServiceModel({
    required super.id,
    required super.name,
    required super.price,
    required super.durationInMinutes,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble(),
      durationInMinutes: data['durationInMinutes'] ?? 60,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'durationInMinutes': durationInMinutes,
    };
  }
}
