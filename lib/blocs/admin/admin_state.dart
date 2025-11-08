part of 'admin_bloc.dart';

enum AdminStatus { initial, loading, success, failure }

class AdminState extends Equatable {
  final AdminStatus status;
  final int activeClients;
  final int todayAppointments;
  final double mrr;
  final int newSubscriptions;
  final int churn;
  final double additionalRevenue;
  final List<UserEntity> clients;
  final UserEntity? selectedClient;
  final List<AppointmentEntity> serviceHistory;
  final List<PaymentEntity> paymentHistory;

  const AdminState({
    this.status = AdminStatus.initial,
    this.activeClients = 0,
    this.todayAppointments = 0,
    this.mrr = 0.0,
    this.newSubscriptions = 0,
    this.churn = 0,
    this.additionalRevenue = 0.0,
    this.clients = const [],
    this.selectedClient,
    this.serviceHistory = const [],
    this.paymentHistory = const [],
  });

  AdminState copyWith({
    AdminStatus? status,
    int? activeClients,
    int? todayAppointments,
    double? mrr,
    int? newSubscriptions,
    int? churn,
    double? additionalRevenue,
    List<UserEntity>? clients,
    UserEntity? selectedClient,
    List<AppointmentEntity>? serviceHistory,
    List<PaymentEntity>? paymentHistory,
  }) {
    return AdminState(
      status: status ?? this.status,
      activeClients: activeClients ?? this.activeClients,
      todayAppointments: todayAppointments ?? this.todayAppointments,
      mrr: mrr ?? this.mrr,
      newSubscriptions: newSubscriptions ?? this.newSubscriptions,
      churn: churn ?? this.churn,
      additionalRevenue: additionalRevenue ?? this.additionalRevenue,
      clients: clients ?? this.clients,
      selectedClient: selectedClient ?? this.selectedClient,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeClients,
        todayAppointments,
        mrr,
        newSubscriptions,
        churn,
        additionalRevenue,
        clients,
        selectedClient,
        serviceHistory,
        paymentHistory,
      ];
}
