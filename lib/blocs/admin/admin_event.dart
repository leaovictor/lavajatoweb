part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class FetchDashboardData extends AdminEvent {}

class FetchClients extends AdminEvent {}

class FetchClientDetails extends AdminEvent {
  final String userId;

  const FetchClientDetails(this.userId);

  @override
  List<Object> get props => [userId];
}

class SuspendSubscription extends AdminEvent {
  final String subscriptionId;

  const SuspendSubscription(this.subscriptionId);

  @override
  List<Object> get props => [subscriptionId];
}

class ReactivateSubscription extends AdminEvent {
  final String subscriptionId;

  const ReactivateSubscription(this.subscriptionId);

  @override
  List<Object> get props => [subscriptionId];
}

class SendPaymentLink extends AdminEvent {
  final String priceId;
  final String userId;

  const SendPaymentLink(this.priceId, this.userId);

  @override
  List<Object> get props => [priceId, userId];
}
