import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:lavajato/domain/entities/appointment_entity.dart';
import 'package:lavajato/domain/entities/payment_entity.dart';
import 'package:lavajato/domain/repositories/admin_repository.dart';
import 'package:lavajato/domain/repositories/payment_repository.dart';
import 'package:lavajato/domain/repositories/stripe_repository.dart';
import 'package:lavajato/domain/repositories/user_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final UserRepository _userRepository;
  final AppointmentRepository _appointmentRepository;
  final StripeRepository _stripeRepository;
  final PaymentRepository _paymentRepository;
  final AdminRepository _adminRepository;

  AdminBloc({
    required UserRepository userRepository,
    required AppointmentRepository appointmentRepository,
    required StripeRepository stripeRepository,
    required PaymentRepository paymentRepository,
    required AdminRepository adminRepository,
  })  : _userRepository = userRepository,
        _appointmentRepository = appointmentRepository,
        _stripeRepository = stripeRepository,
        _paymentRepository = paymentRepository,
        _adminRepository = adminRepository,
        super(const AdminState()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<FetchClients>(_onFetchClients);
    on<FetchClientDetails>(_onFetchClientDetails);
    on<SuspendSubscription>(_onSuspendSubscription);
    on<ReactivateSubscription>(_onReactivateSubscription);
    on<SendPaymentLink>(_onSendPaymentLink);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final activeClients = await _userRepository.getActiveClientCount();
      final todayAppointments = await _appointmentRepository.getTodayAppointmentCount();
      final stripeMetrics = await _stripeRepository.getDashboardMetrics();

      emit(state.copyWith(
        status: AdminStatus.success,
        activeClients: activeClients,
        todayAppointments: todayAppointments,
        mrr: stripeMetrics['mrr'],
        newSubscriptions: stripeMetrics['newSubscriptions'],
        churn: stripeMetrics['churn'],
        additionalRevenue: stripeMetrics['additionalRevenue'],
      ));
    } catch (_) {
      emit(state.copyWith(status: AdminStatus.failure));
    }
  }

  Future<void> _onFetchClients(
    FetchClients event,
    Emitter<AdminState> emit,
  ) async {
    await emit.forEach(
      _userRepository.getClients(),
      onData: (clients) => state.copyWith(
        status: AdminStatus.success,
        clients: clients,
      ),
      onError: (_, __) => state.copyWith(status: AdminStatus.failure),
    );
  }

  Future<void> _onFetchClientDetails(
    FetchClientDetails event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final client = await _userRepository.getClient(event.userId);
      final serviceHistory = await _appointmentRepository.getUserAppointments(event.userId);
      final paymentHistory = await _paymentRepository.getPaymentHistory(event.userId);

      emit(state.copyWith(
        status: AdminStatus.success,
        selectedClient: client,
        serviceHistory: serviceHistory,
        paymentHistory: paymentHistory,
      ));
    } catch (_) {
      emit(state.copyWith(status: AdminStatus.failure));
    }
  }

  Future<void> _onSuspendSubscription(
    SuspendSubscription event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.suspendSubscription(event.subscriptionId);
      add(FetchClientDetails(state.selectedClient!.id));
    } catch (_) {
      // Handle error
    }
  }

  Future<void> _onReactivateSubscription(
    ReactivateSubscription event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.reactivateSubscription(event.subscriptionId);
      add(FetchClientDetails(state.selectedClient!.id));
    } catch (_) {
      // Handle error
    }
  }

  Future<void> _onSendPaymentLink(
    SendPaymentLink event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.sendPaymentLink(event.priceId, event.userId);
    } catch (_) {
      // Handle error
    }
  }
}
