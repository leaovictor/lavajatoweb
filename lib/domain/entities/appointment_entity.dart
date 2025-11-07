import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String? id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  const AppointmentEntity({
    this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  @override
  List<Object?> get props => [id, userId, serviceId, serviceName, startTime, endTime, status];
}
