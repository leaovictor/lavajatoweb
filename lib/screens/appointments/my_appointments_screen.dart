import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/repositories/auth_repository.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  late Future<List<AppointmentEntity>> _appointmentsFuture;
  List<AppointmentEntity> _upcomingAppointments = [];
  List<AppointmentEntity> _pastAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    final appointmentRepository =
        Provider.of<AppointmentRepository>(context, listen: false);
    final user = authRepository.currentUser;

    if (user != null) {
      _appointmentsFuture =
          appointmentRepository.getUserAppointments(user.uid).then((appointments) {
        final now = DateTime.now();
        setState(() {
          _upcomingAppointments =
              appointments.where((a) => a.startTime.isAfter(now)).toList();
          _pastAppointments =
              appointments.where((a) => a.startTime.isBefore(now)).toList();
        });
        return appointments;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Agendamentos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Próximos'),
              Tab(text: 'Histórico'),
            ],
          ),
        ),
        body: FutureBuilder<List<AppointmentEntity>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('Nenhum agendamento encontrado.'));
            }

            return TabBarView(
              children: [
                _buildAppointmentsList(_upcomingAppointments),
                _buildAppointmentsList(_pastAppointments),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentEntity> appointments) {
    if (appointments.isEmpty) {
      return const Center(child: Text('Nenhum agendamento nesta categoria.'));
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return ListTile(
          title: Text(appointment.serviceName),
          subtitle: Text(
            DateFormat('dd/MM/yyyy HH:mm').format(appointment.startTime),
          ),
          trailing: Text(
            appointment.status,
            style: TextStyle(
              color: appointment.status == 'canceled' ? Colors.red : Colors.green,
            ),
          ),
        );
      },
    );
  }
}
