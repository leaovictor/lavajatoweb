import '../../domain/entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentEntity>> getUserAppointments(String userId);
  Future<List<AppointmentEntity>> getAppointmentsForDay(DateTime date);
}
