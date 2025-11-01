import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String clienteId;
  final String serviceName;
  final DateTime data;
  final String hora;
  final String status;

  Appointment({
    required this.id,
    required this.clienteId,
    required this.serviceName,
    required this.data,
    required this.hora,
    required this.status,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      clienteId: data['clienteId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      data: (data['data'] as Timestamp).toDate(),
      hora: data['hora'] ?? '',
      status: data['status'] ?? 'pendente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'serviceName': serviceName,
      'data': Timestamp.fromDate(data),
      'hora': hora,
      'status': status,
    };
  }
}
