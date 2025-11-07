import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavajato/blocs/admin/admin_bloc.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBloc(
        appointmentRepository: context.read<AppointmentRepository>(),
      )..add(LoadAppointmentsForDay(_selectedDay)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel Administrativo'),
        ),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                context
                    .read<AdminBloc>()
                    .add(LoadAppointmentsForDay(selectedDay));
              },
            ),
            Expanded(
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state is AdminLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AdminError) {
                    return Center(child: Text(state.message));
                  } else if (state is AdminLoaded) {
                    if (state.appointments.isEmpty) {
                      return const Center(
                          child: Text('Nenhum agendamento para este dia.'));
                    }
                    return ListView.builder(
                      itemCount: state.appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = state.appointments[index];
                        return ListTile(
                          title: Text(appointment.serviceName),
                          subtitle: Text(
                              'Cliente: ${appointment.userId} - Status: ${appointment.status}'),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
