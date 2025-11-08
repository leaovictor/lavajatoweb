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
