import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/data/models/appointment_model.dart';
import 'package:lavajato/domain/entities/appointment_entity.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';

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
  Future<List<AppointmentEntity>> getAllAppointmentsForDay(DateTime date) async {
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
  Future<List<AppointmentEntity>> getAppointmentsForDay(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('agendamentos')
          .where('userId', isEqualTo: userId)
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
}
