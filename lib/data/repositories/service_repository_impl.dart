import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';
import '../models/service_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final FirebaseFirestore _firestore;

  ServiceRepositoryImpl(this._firestore);

  @override
  Future<List<ServiceEntity>> getServices() async {
    try {
      final querySnapshot = await _firestore.collection('servicos').get();
      return querySnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }
}
