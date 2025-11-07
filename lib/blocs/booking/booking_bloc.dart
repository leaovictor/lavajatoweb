import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lavajato/domain/entities/car_entity.dart';
import 'package:lavajato/domain/entities/service_entity.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc() : super(const BookingState()) {
    on<ServiceSelected>((event, emit) {
      emit(state.copyWith(service: event.service));
    });

    on<VehicleSelected>((event, emit) {
      emit(state.copyWith(vehicle: event.vehicle));
    });

    on<DateTimeSelected>((event, emit) {
      emit(state.copyWith(dateTime: event.dateTime));
    });
  }
}
