import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';
import 'package:lavajato/domain/repositories/stripe_repository.dart';
import 'package:lavajato/domain/repositories/user_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final UserRepository _userRepository;
  final AppointmentRepository _appointmentRepository;
  final StripeRepository _stripeRepository;

  AdminBloc({
    required UserRepository userRepository,
    required AppointmentRepository appointmentRepository,
    required StripeRepository stripeRepository,
  })  : _userRepository = userRepository,
        _appointmentRepository = appointmentRepository,
        _stripeRepository = stripeRepository,
        super(const AdminState()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<FetchClients>(_onFetchClients);
    on<FetchClientDetails>(_onFetchClientDetails);
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
      emit(state.copyWith(
        status: AdminStatus.success,
        selectedClient: client,
      ));
    } catch (_) {
      emit(state.copyWith(status: AdminStatus.failure));
    }
  }
}
