part of 'booking_bloc.dart';

class BookingState extends Equatable {
  final ServiceEntity? service;
  final CarEntity? vehicle;
  final DateTime? dateTime;

  const BookingState({
    this.service,
    this.vehicle,
    this.dateTime,
  });

  BookingState copyWith({
    ServiceEntity? service,
    CarEntity? vehicle,
    DateTime? dateTime,
  }) {
    return BookingState(
      service: service ?? this.service,
      vehicle: vehicle ?? this.vehicle,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  @override
  List<Object?> get props => [service, vehicle, dateTime];
}
