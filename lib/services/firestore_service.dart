import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getUser(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Stream<QuerySnapshot> getServices() {
    return _db.collection('services').snapshots();
  }

  Stream<QuerySnapshot> getAppointmentsForDay(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection('agendamentos')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots();
  }

  Future<void> addAppointment(Map<String, dynamic> appointmentData) {
    return _db.collection('agendamentos').add(appointmentData);
  }
}
