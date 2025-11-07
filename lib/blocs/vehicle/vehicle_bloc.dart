import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lavajato/domain/entities/car_entity.dart';
import 'package:lavajato/domain/repositories/vehicle_repository.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository _vehicleRepository;

  VehicleBloc({required VehicleRepository vehicleRepository})
      : _vehicleRepository = vehicleRepository,
        super(VehicleInitial()) {
    on<LoadVehicles>((event, emit) async {
      emit(VehicleLoading());
      try {
        final vehicles = await _vehicleRepository.getVehicles();
        emit(VehicleLoaded(vehicles));
      } catch (e) {
        emit(VehicleError(e.toString()));
      }
    });

    on<AddVehicle>((event, emit) async {
      try {
        await _vehicleRepository.addVehicle(event.car);
        add(LoadVehicles());
      } catch (e) {
        emit(VehicleError(e.toString()));
      }
    });
  }
}
