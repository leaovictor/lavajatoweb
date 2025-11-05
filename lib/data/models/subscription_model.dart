import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  SubscriptionModel({
    required String planId,
    required String status,
    required DateTime currentPeriodEnd,
  }) : super(
          planId: planId,
          status: status,
          currentPeriodEnd: currentPeriodEnd,
        );

  factory SubscriptionModel.fromMap(Map<String, dynamic> data) {
    return SubscriptionModel(
      planId: data['planId'] ?? '',
      status: data['status'] ?? '',
      currentPeriodEnd: (data['currentPeriodEnd'] as Timestamp).toDate(),
    );
  }
}
