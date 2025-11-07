import 'package:equatable/equatable.dart';

class CarEntity extends Equatable {
  final String id;
  final String make;
  final String model;
  final String licensePlate;

  const CarEntity({
    required this.id,
    required this.make,
    required this.model,
    required this.licensePlate,
  });

  @override
  List<Object> get props => [id, make, model, licensePlate];
}
