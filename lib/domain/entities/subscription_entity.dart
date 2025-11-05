class SubscriptionEntity {
  final String planId;
  final String status;
  final DateTime currentPeriodEnd;

  SubscriptionEntity({
    required this.planId,
    required this.status,
    required this.currentPeriodEnd,
  });
}
