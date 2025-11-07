part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class LoadAppointmentsForDay extends AdminEvent {
  final DateTime date;

  const LoadAppointmentsForDay(this.date);

  @override
  List<Object> get props => [date];
}
