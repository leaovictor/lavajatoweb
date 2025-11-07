import 'package:lavajato/domain/entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentEntity>> getAllAppointmentsForDay(DateTime date);
  Future<List<AppointmentEntity>> getUserAppointments(String userId);
  Future<List<AppointmentEntity>> getAppointmentsForDay(String userId, DateTime date);
  Future<void> createAppointment(AppointmentEntity appointment);
}
