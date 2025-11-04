import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/data/models/car_model.dart';
import 'package:lavajato/data/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setUser(UserModel user) {
    return _db.collection('users').doc(user.id).set(user.toMap());
  }

  Stream<DocumentSnapshot> getUser(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) {
    return _db.collection('users').doc(userId).update(data);
  }

  Future<void> addCar(String userId, CarModel car) {
    return _db.collection('users').doc(userId).collection('cars').add(car.toMap());
  }

  Stream<QuerySnapshot> getCars(String userId) {
    return _db.collection('users').doc(userId).collection('cars').snapshots();
  }

  Stream<QuerySnapshot> getServices() {
    return _db.collection('services').snapshots();
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
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots();
  }
}
