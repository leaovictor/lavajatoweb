import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/models/appointment_model.dart';
import 'package:lavajato/models/client_model.dart';
import 'package:lavajato/services/firestore_service.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(
        child: Text('Faça login para ver seus agendamentos.'),
      );
    }

    return Column(
      children: [
        _buildSubscriptionStatus(),
        Expanded(
          child: StreamBuilder<List<Appointment>>(
            stream: _firestoreService.getMyAppointments(_user!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(
                    child: Text('Erro ao carregar agendamentos.'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('Você não possui agendamentos.'));
              }

              final now = DateTime.now();
              final upcoming = snapshot.data!
                  .where((a) => a.hora.isAfter(now))
                  .toList();
              final past = snapshot.data!
                  .where((a) => a.hora.isBefore(now))
                  .toList();

              return ListView(
                children: [
                  if (upcoming.isNotEmpty)
                    _buildAppointmentList('Próximas Reservas', upcoming),
                  if (past.isNotEmpty)
                    _buildAppointmentList('Histórico', past),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionStatus() {
    return StreamBuilder<Client>(
      stream: _firestoreService.getUser(_user!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final client = snapshot.data!;
        final status = client.subscriptionStatus ?? 'inativa';
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Status da Assinatura: ${status.toUpperCase()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentList(String title, List<Appointment> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final formattedDate =
                DateFormat('dd/MM/yyyy').format(appointment.data);
            final formattedTime = DateFormat('HH:mm').format(appointment.hora);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text(
                  appointment.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Em $formattedDate às $formattedTime'),
                trailing: Text(appointment.status),
              ),
            );
          },
        ),
      ],
    );
  }
}
