import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepositoryImpl(this._firestore);

  @override
  Future<List<AppointmentEntity>> getUserAppointments(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('agendamentos')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // It's a good practice to handle errors, e.g., by logging them
      // or rethrowing a more specific exception.
      print('Error fetching appointments: $e');
      rethrow;
    }
  }
}
