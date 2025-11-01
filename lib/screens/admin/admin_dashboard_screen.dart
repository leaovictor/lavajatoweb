import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/models/appointment_model.dart';
import 'package:lavajato/models/client_model.dart';
import 'package:lavajato/services/firestore_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel Administrativo'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_day), text: 'Agendamentos do Dia'),
              Tab(icon: Icon(Icons.people), text: 'Assinantes Ativos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DailyAppointmentsView(),
            _ActiveSubscribersView(),
          ],
        ),
      ),
    );
  }
}

class _ActiveSubscribersView extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Client>>(
      stream: _firestoreService.getActiveSubscribers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar assinantes.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum assinante ativo.'));
        }

        final subscribers = snapshot.data!;

        return ListView.builder(
          itemCount: subscribers.length,
          itemBuilder: (context, index) {
            final subscriber = subscribers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(subscriber.name),
                subtitle: Text(subscriber.email),
              ),
            );
          },
        );
      },
    );
  }
}

class _DailyAppointmentsView extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: _firestoreService.getAllAppointmentsForDay(DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar agendamentos.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum agendamento para hoje.'));
        }

        final appointments = snapshot.data!;

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(appointment.serviceName),
                subtitle: Text(
                    'Cliente: ${appointment.clienteId} - ${DateFormat('HH:mm').format(appointment.hora)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    _firestoreService.cancelAppointment(appointment.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
