import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:lavajato/models/appointment_model.dart';
import 'package:lavajato/screens/home/home_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getMyAppointments(_user!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar agendamentos.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Você não possui agendamentos.'));
          }

          final allAppointments = snapshot.data!.docs
              .map((doc) => Appointment.fromFirestore(doc))
              .toList();

          final upcomingAppointments = allAppointments.where((a) => a.startTime.isAfter(DateTime.now())).toList();
          final pastAppointments = allAppointments.where((a) => a.startTime.isBefore(DateTime.now())).toList();

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              if (upcomingAppointments.isNotEmpty)
                _buildSectionTitle('Próximos Agendamentos'),
              ...upcomingAppointments.map((app) => _buildAppointmentCard(app)),

              if (pastAppointments.isNotEmpty)
                _buildSectionTitle('Agendamentos Passados'),
              ...pastAppointments.map((app) => _buildAppointmentCard(app)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(appointment.startTime);
    final formattedTime = DateFormat('HH:mm').format(appointment.startTime);
    final isCancelled = appointment.status == 'Cancelado';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      color: isCancelled ? Colors.grey[300] : null,
      child: ListTile(
        title: Text(
          appointment.serviceName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isCancelled ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Data: $formattedDate às $formattedTime'),
            if (appointment.carInfo != null && appointment.carInfo!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('Veículo: ${appointment.carInfo}'),
              ),
            if (isCancelled)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text('Status: Cancelado', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        leading: Icon(
          isCancelled ? Icons.cancel : (appointment.startTime.isBefore(DateTime.now()) ? Icons.check_circle : Icons.history),
          color: isCancelled ? Colors.red : (appointment.startTime.isBefore(DateTime.now()) ? Colors.green : Colors.blue),
        ),
      ),
    );
  }
}
