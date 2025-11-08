import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepositoryImpl(this._firestore);

  @override
  Future<void> createAppointment(AppointmentEntity appointment) async {
    try {
      final appointmentModel = AppointmentModel(
        userId: appointment.userId,
        serviceId: appointment.serviceId,
        serviceName: appointment.serviceName,
        startTime: appointment.startTime,
        endTime: appointment.endTime,
        status: appointment.status,
      );
      await _firestore.collection('agendamentos').add(appointmentModel.toFirestore());
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }

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
      print('Error fetching user appointments: $e');
      rethrow;
    }
  }

  @override
  Future<List<AppointmentEntity>> getAppointmentsForDay(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('agendamentos')
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching appointments for day: $e');
      rethrow;
    }
  }

  @override
  Future<int> getTodayAppointmentCount() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('agendamentos')
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error fetching today\'s appointment count: $e');
      rethrow;
    }
  }
}
