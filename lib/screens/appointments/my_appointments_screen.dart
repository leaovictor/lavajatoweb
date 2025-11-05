import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/models/appointment_model.dart';
import 'package:lavajato/data/services/firestore_service.dart';

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

          final appointments = snapshot.data!.docs
              .map((doc) => Appointment.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final formattedDate = DateFormat('dd/MM/yyyy').format(appointment.startTime);
              final formattedTime = DateFormat('HH:mm').format(appointment.startTime);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    appointment.serviceName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data: $formattedDate às $formattedTime'),
                      if (appointment.carInfo != null)
                        Text('Veículo: ${appointment.carInfo}'),
                    ],
                  ),
                  leading: Icon(
                    appointment.startTime.isBefore(DateTime.now())
                        ? Icons.check_circle
                        : Icons.history,
                    color: appointment.startTime.isBefore(DateTime.now())
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
