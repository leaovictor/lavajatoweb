import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lavajato/domain/entities/appointment_entity.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AppointmentRepository _appointmentRepository;

  AdminBloc({required AppointmentRepository appointmentRepository})
      : _appointmentRepository = appointmentRepository,
        super(AdminInitial()) {
    on<LoadAppointmentsForDay>((event, emit) async {
      emit(AdminLoading());
      try {
        final appointments = await _appointmentRepository.getAllAppointmentsForDay(event.date);
        emit(AdminLoaded(appointments));
      } catch (e) {
        emit(AdminError(e.toString()));
      }
    });
  }
}
