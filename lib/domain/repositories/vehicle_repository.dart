import 'package:lavajato/domain/entities/car_entity.dart';

abstract class VehicleRepository {
  Future<List<CarEntity>> getVehicles();
  Future<void> addVehicle(CarEntity car);
}
