import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/models/plan_model.dart';

class PlanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'plans';

  Stream<List<Plan>> getPlans() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Plan.fromFirestore(doc)).toList());
  }

  Future<void> addPlan(Plan plan) {
    return _db.collection(_collectionPath).add(plan.toMap());
  }

  Future<void> updatePlan(Plan plan) {
    return _db.collection(_collectionPath).doc(plan.id).update(plan.toMap());
  }

  Future<void> deletePlan(String planId) {
    return _db.collection(_collectionPath).doc(planId).delete();
  }

  Future<Plan?> getPlanByName(String name) async {
    final snapshot = await _db
        .collection(_collectionPath)
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return Plan.fromFirestore(snapshot.docs.first);
    }
    return null;
  }
}
