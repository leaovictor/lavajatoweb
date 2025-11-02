import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String clienteId;
  final String serviceName;
  final DateTime data;
  final DateTime hora;
  final String status;
  final int duration; // Add duration field

  Appointment({
    required this.id,
    required this.clienteId,
    required this.serviceName,
    required this.data,
    required this.hora,
    required this.status,
    required this.duration, // Add to constructor
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      clienteId: data['clienteId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      data: data['data'] != null ? (data['data'] as Timestamp).toDate() : DateTime.now(),
      hora: data['hora'] != null ? (data['hora'] as Timestamp).toDate() : DateTime.now(),
      status: data['status'] ?? 'pendente',
      duration: data['duration'] ?? 0, // Add duration from firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'serviceName': serviceName,
      'data': Timestamp.fromDate(data),
      'hora': Timestamp.fromDate(hora),
      'status': status,
      'duration': duration, // Add duration to map
    };
  }
}
