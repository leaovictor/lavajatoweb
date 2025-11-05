class NotificationService {
  Future<void> sendAppointmentCancellationNotification(String userId, String serviceName, DateTime startTime) async {
    // Simulate sending a notification
    print('---');
    print('Simulating notification to user: $userId');
    print('Subject: Agendamento Cancelado');
    print('Body: Seu agendamento para o serviço "$serviceName" em $startTime foi cancelado pelo administrador.');
    print('---');
  }
}
