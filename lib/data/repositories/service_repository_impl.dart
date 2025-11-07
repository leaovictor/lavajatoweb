import 'package:lavajato/data/models/service_model.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:lavajato/domain/entities/service_entity.dart';
import 'package:lavajato/domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final FirestoreService _firestoreService;

  ServiceRepositoryImpl({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<List<ServiceEntity>> getServices() async {
    final snapshot = await _firestoreService.getServices().first;
    return snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
  }
}
