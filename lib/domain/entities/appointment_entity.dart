class AppointmentEntity {
  final String? id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  AppointmentEntity({
    this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
}
