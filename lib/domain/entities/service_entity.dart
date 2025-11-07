import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final int durationInMinutes;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.durationInMinutes,
  });

  @override
  List<Object> get props => [id, name, price, durationInMinutes];
}
