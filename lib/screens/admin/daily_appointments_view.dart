import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:lavajato/data/services/notification_service.dart';
import 'package:lavajato/models/appointment_model.dart';

class DailyAppointmentsView extends StatelessWidget {
  const DailyAppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final notificationService = NotificationService();

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
            final bool isCancelled = appointment.status == 'Cancelado';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    Text('Horário: $formattedTime'),
                    if (appointment.carInfo != null)
                      Text('Veículo: ${appointment.carInfo}'),
                  ],
                ),
                trailing: isCancelled
                    ? const Text('Cancelado')
                    : TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () async {
                          await firestoreService.cancelAppointment(appointment.id);
                          await notificationService.sendAppointmentCancellationNotification(
                            appointment.userId,
                            appointment.serviceName,
                            appointment.startTime,
                          );
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
