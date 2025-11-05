import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/repositories/plan_repository.dart';
import 'package:lavajato/models/plan_model.dart';

class PlanRepositoryImpl implements PlanRepository {
  final FirebaseFirestore _firestore;

  PlanRepositoryImpl(this._firestore);

  @override
  Future<List<Plan>> getPlans() async {
    try {
      final snapshot = await _firestore.collection('plans').get();
      return snapshot.docs.map((doc) => Plan.fromFirestore(doc)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting plans: $e');
      return [];
    }
  }
}
