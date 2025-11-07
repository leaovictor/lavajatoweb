import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    String? id,
    required String userId,
    required String serviceId,
    required String serviceName,
    required DateTime startTime,
    required DateTime endTime,
    required String status,
  }) : super(
          id: id,
          userId: userId,
          serviceId: serviceId,
          serviceName: serviceName,
          startTime: startTime,
          endTime: endTime,
          status: status,
        );

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      userId: data['userId'],
      serviceId: data['serviceId'],
      serviceName: data['serviceName'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
    };
  }
}
