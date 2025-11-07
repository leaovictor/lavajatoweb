import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lavajato/domain/entities/service_entity.dart';
import 'package:lavajato/domain/repositories/service_repository.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository _serviceRepository;

  ServiceBloc({required ServiceRepository serviceRepository})
      : _serviceRepository = serviceRepository,
        super(ServiceInitial()) {
    on<LoadServices>((event, emit) async {
      emit(ServiceLoading());
      try {
        final services = await _serviceRepository.getServices();
        emit(ServiceLoaded(services));
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });
  }
}
