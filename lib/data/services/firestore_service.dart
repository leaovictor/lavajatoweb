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

  Stream<QuerySnapshot> getSubscriptionPlans() {
    return _db.collection('plans').snapshots();
  }
}
