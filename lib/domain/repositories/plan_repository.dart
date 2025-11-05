import 'package:lavajato/models/plan_model.dart';

abstract class PlanRepository {
  Future<List<Plan>> getPlans();
}
