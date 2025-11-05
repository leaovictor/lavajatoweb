import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/domain/entities/appointment_entity.dart';
import 'package:lavajato/domain/entities/service_entity.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/widgets/summary_row.dart';
import 'package:provider/provider.dart';

class ConfirmationScreen extends StatefulWidget {
  final ServiceEntity service;
  final DateTime selectedDateTime;

  const ConfirmationScreen({
    super.key,
    required this.service,
    required this.selectedDateTime,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _isCreatingAppointment = false;

  Future<void> _confirmAppointment() async {
    setState(() {
      _isCreatingAppointment = true;
    });

    try {
      final authRepository = Provider.of<AuthRepository>(context, listen: false);
      final appointmentRepository = Provider.of<AppointmentRepository>(context, listen: false);
      final user = authRepository.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final newAppointment = AppointmentEntity(
        userId: user.uid,
        serviceId: widget.service.id,
        serviceName: widget.service.name,
        startTime: widget.selectedDateTime,
        endTime: widget.selectedDateTime.add(Duration(minutes: widget.service.durationInMinutes)),
        status: 'confirmed',
      );

      await appointmentRepository.createAppointment(newAppointment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento confirmado com sucesso!')),
        );
        // Navigate back to the root of the navigation stack (main screen)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar agendamento: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingAppointment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(widget.selectedDateTime);
    final formattedTime = DateFormat('HH:mm').format(widget.selectedDateTime);

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
                    SummaryRow(label: 'Serviço:', value: widget.service.name),
                    const Divider(height: 24),
                    SummaryRow(label: 'Data:', value: formattedDate),
                    const Divider(height: 24),
                    SummaryRow(label: 'Hora:', value: formattedTime),
                    const Divider(height: 24),
                    SummaryRow(label: 'Duração:', value: '${widget.service.durationInMinutes} min'),
                    const Divider(height: 24),
                    SummaryRow(
                      label: 'Preço:',
                      value: 'R\$ ${widget.service.price.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isCreatingAppointment ? null : _confirmAppointment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isCreatingAppointment
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirmar Agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}
