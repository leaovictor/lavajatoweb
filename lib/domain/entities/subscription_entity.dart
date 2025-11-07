import 'package:equatable/equatable.dart';

class SubscriptionEntity extends Equatable {
  final String planId;
  final String status;
  final DateTime currentPeriodEnd;

  const SubscriptionEntity({
    required this.planId,
    required this.status,
    required this.currentPeriodEnd,
  });

  @override
  List<Object> get props => [planId, status, currentPeriodEnd];
}
