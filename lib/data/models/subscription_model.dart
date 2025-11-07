import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required String planId,
    required String status,
    required DateTime currentPeriodEnd,
  }) : super(
          planId: planId,
          status: status,
          currentPeriodEnd: currentPeriodEnd,
        );

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      planId: map['planId'],
      status: map['status'],
      currentPeriodEnd: (map['currentPeriodEnd'] as Timestamp).toDate(),
    );
  }
}
