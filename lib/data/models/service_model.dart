import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required String id,
    required String name,
    required double price,
    required int durationInMinutes,
  }) : super(
          id: id,
          name: name,
          price: price,
          durationInMinutes: durationInMinutes,
        );

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'],
      price: (data['price'] as num).toDouble(),
      durationInMinutes: data['durationInMinutes'],
    );
  }
}
