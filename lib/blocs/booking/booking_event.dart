part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object> get props => [];
}

class ServiceSelected extends BookingEvent {
  final ServiceEntity service;

  const ServiceSelected(this.service);

  @override
  List<Object> get props => [service];
}

class VehicleSelected extends BookingEvent {
  final CarEntity vehicle;

  const VehicleSelected(this.vehicle);

  @override
  List<Object> get props => [vehicle];
}

class DateTimeSelected extends BookingEvent {
  final DateTime dateTime;

  const DateTimeSelected(this.dateTime);

  @override
  List<Object> get props => [dateTime];
}
