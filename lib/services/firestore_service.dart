import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getServices() {
    return _db.collection('services').snapshots();
  }

  Future<void> addService(Map<String, dynamic> serviceData) {
    return _db.collection('services').add(serviceData);
  }

  Future<void> addAppointment(Map<String, dynamic> appointmentData) {
    return _db.collection('appointments').add(appointmentData);
  }

  Stream<QuerySnapshot> getMyAppointments(String userId) {
    return _db
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAppointmentsForDay(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection('appointments')
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots();
  }
}
