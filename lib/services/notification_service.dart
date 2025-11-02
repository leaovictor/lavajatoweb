import 'package:lavajato/models/appointment_model.dart';
import 'package:lavajato/models/client_model.dart';

class NotificationService {
  // Simula o envio de um e-mail de confirmação de cadastro.
  // Em um aplicativo real, isso seria tratado por um backend ou
  // um serviço de e-mail transacional (ex: Firebase Cloud Functions + SendGrid).
  Future<void> sendRegistrationConfirmation(Client client) async {
    print('--- SIMULAÇÃO DE NOTIFICAÇÃO ---');
    print('Enviando e-mail de confirmação de cadastro para: ${client.email}');
    print('Assunto: Bem-vindo ao LavaJato!');
    print('Corpo: Olá, ${client.name}! Sua conta foi criada com sucesso.');
    print('---------------------------------');
  }

  // Simula o envio de um e-mail de confirmação de agendamento.
  Future<void> sendAppointmentConfirmation(Appointment appointment) async {
    print('--- SIMULAÇÃO DE NOTIFICAÇÃO ---');
    print('Enviando e-mail de confirmação de agendamento...');
    print('Serviço: ${appointment.serviceName}');
    print('Data: ${appointment.data}');
    print('Hora: ${appointment.hora}');
    print('---------------------------------');
  }
}
