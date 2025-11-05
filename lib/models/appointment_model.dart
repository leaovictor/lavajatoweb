import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final DateTime startTime;
  final DateTime endTime;
  final String? carId;
  final String? carInfo;

  Appointment({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
    this.carId,
    this.carInfo,
  });

  // Factory constructor to create an Appointment from a map (e.g., from Firestore)
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      userId: data['userId'],
      serviceId: data['serviceId'],
      serviceName: data['serviceName'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      carId: data['carId'],
      carInfo: data['carInfo'],
    );
  }

  // Method to convert an Appointment to a map (e.g., for writing to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'carId': carId,
      'carInfo': carInfo,
    };
  }
}
