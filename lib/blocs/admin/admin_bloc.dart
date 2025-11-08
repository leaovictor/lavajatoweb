import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';
import 'package:lavajato/domain/repositories/user_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final UserRepository _userRepository;
  final AppointmentRepository _appointmentRepository;

  AdminBloc({
    required UserRepository userRepository,
    required AppointmentRepository appointmentRepository,
  })  : _userRepository = userRepository,
        _appointmentRepository = appointmentRepository,
        super(const AdminState()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<FetchClients>(_onFetchClients);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      // Placeholder logic
      final activeClients = await _userRepository.getActiveClientCount();
      final todayAppointments = await _appointmentRepository.getTodayAppointmentCount();

      emit(state.copyWith(
        status: AdminStatus.success,
        activeClients: activeClients,
        todayAppointments: todayAppointments,
        mrr: 1234.56, // Placeholder
        newSubscriptions: 12, // Placeholder
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
}
