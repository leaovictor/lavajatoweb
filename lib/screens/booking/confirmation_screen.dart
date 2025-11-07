import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/domain/entities/appointment_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavajato/blocs/booking/booking_bloc.dart';
import 'package:lavajato/domain/entities/service_entity.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/widgets/summary_row.dart';
import 'package:provider/provider.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  Future<void> _confirmAppointment(BuildContext context, ValueNotifier<bool> isCreatingAppointment) async {
    isCreatingAppointment.value = true;

    try {
      final bookingState = context.read<BookingBloc>().state;
      final authRepository = Provider.of<AuthRepository>(context, listen: false);
      final appointmentRepository = Provider.of<AppointmentRepository>(context, listen: false);
      final user = authRepository.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }
      if (bookingState.service == null || bookingState.dateTime == null) {
        throw Exception('Booking information is incomplete');
      }

      final newAppointment = AppointmentEntity(
        userId: user.uid,
        serviceId: bookingState.service!.id,
        serviceName: bookingState.service!.name,
        startTime: bookingState.dateTime!,
        endTime: bookingState.dateTime!.add(Duration(minutes: bookingState.service!.durationInMinutes)),
        status: 'confirmed',
      );

      await appointmentRepository.createAppointment(newAppointment);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento confirmado com sucesso!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao confirmar agendamento: $e')),
      );
    } finally {
      isCreatingAppointment.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = context.watch<BookingBloc>().state;
    final service = bookingState.service;
    final selectedDateTime = bookingState.dateTime;

    if (service == null || selectedDateTime == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(child: Text('Informações do agendamento incompletas.')),
      );
    }

    final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDateTime);
    final formattedTime = DateFormat('HH:mm').format(selectedDateTime);
    final isCreatingAppointment = ValueNotifier<bool>(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirme seu Agendamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo do Agendamento',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    SummaryRow(label: 'Serviço:', value: service.name),
                    const Divider(height: 24),
                    SummaryRow(label: 'Data:', value: formattedDate),
                    const Divider(height: 24),
                    SummaryRow(label: 'Hora:', value: formattedTime),
                    const Divider(height: 24),
                    SummaryRow(label: 'Duração:', value: '${service.durationInMinutes} min'),
                    const Divider(height: 24),
                    SummaryRow(
                      label: 'Preço:',
                      value: 'R\$ ${service.price.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ValueListenableBuilder<bool>(
              valueListenable: isCreatingAppointment,
              builder: (context, isLoading, child) {
                return ElevatedButton(
                  onPressed: isLoading ? null : () => _confirmAppointment(context, isCreatingAppointment),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Confirmar Agendamento'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
