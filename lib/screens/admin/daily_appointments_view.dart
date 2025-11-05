import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:lavajato/models/appointment_model.dart';

class DailyAppointmentsView extends StatelessWidget {
  const DailyAppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getAllAppointmentsForDay(DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar agendamentos.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum agendamento para hoje.'));
        }

        final appointments = snapshot.data!.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList();

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
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
                    Text('Horário: $formattedTime'),
                    if (appointment.carInfo != null)
                      Text('Veículo: ${appointment.carInfo}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
