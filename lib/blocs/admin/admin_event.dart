part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class FetchDashboardData extends AdminEvent {}

class FetchClients extends AdminEvent {}
