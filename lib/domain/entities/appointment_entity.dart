class AppointmentEntity {
  final String id;
  final String serviceName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  AppointmentEntity({
    required this.id,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
}
