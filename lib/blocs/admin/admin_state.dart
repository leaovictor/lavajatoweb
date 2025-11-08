part of 'admin_bloc.dart';

enum AdminStatus { initial, loading, success, failure }

class AdminState extends Equatable {
  final AdminStatus status;
  final int activeClients;
  final int todayAppointments;
  final double mrr;
  final int newSubscriptions;
  final List<UserEntity> clients;

  const AdminState({
    this.status = AdminStatus.initial,
    this.activeClients = 0,
    this.todayAppointments = 0,
    this.mrr = 0.0,
    this.newSubscriptions = 0,
    this.clients = const [],
  });

  AdminState copyWith({
    AdminStatus? status,
    int? activeClients,
    int? todayAppointments,
    double? mrr,
    int? newSubscriptions,
    List<UserEntity>? clients,
  }) {
    return AdminState(
      status: status ?? this.status,
      activeClients: activeClients ?? this.activeClients,
      todayAppointments: todayAppointments ?? this.todayAppointments,
      mrr: mrr ?? this.mrr,
      newSubscriptions: newSubscriptions ?? this.newSubscriptions,
      clients: clients ?? this.clients,
    );
  }

  @override
  List<Object> get props => [status, activeClients, todayAppointments, mrr, newSubscriptions, clients];
}
