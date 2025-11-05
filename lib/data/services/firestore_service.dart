import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/data/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getUser(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  Future<void> setUser(UserModel user) {
    return _db.collection('users').doc(user.id).set(user.toMap());
  }

  Stream<QuerySnapshot> getUsers() {
    return _db.collection('users').snapshots();
  }

  Stream<QuerySnapshot> getAllAppointmentsForDay(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection('appointments')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('startTime')
        .snapshots();
  }

  Stream<QuerySnapshot> getSubscriptionPlans() {
    return _db.collection('plans').snapshots();
  }
}
