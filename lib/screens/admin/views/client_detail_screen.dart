import 'package:flutter/material.dart';
import 'package:lavajato/domain/entities/user_entity.dart';

class ClientDetailScreen extends StatelessWidget {
  final UserEntity client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(client.name ?? 'Detalhes do Cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Histórico de Pagamentos', style: Theme.of(context).textTheme.titleLarge),
            // Placeholder for payment history
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Pagamento Mensal - Plano Básico'),
              subtitle: Text('R\$ 49,90 - 01/11/2025'),
            ),
            const Divider(),
            Text('Histórico de Serviços', style: Theme.of(context).textTheme.titleLarge),
            // Placeholder for service history
            const ListTile(
              leading: Icon(Icons.local_car_wash),
              title: Text('Lavagem Completa'),
              subtitle: Text('05/11/2025'),
            ),
            const Divider(),
            Text('Ações do Admin', style: Theme.of(context).textTheme.titleLarge),
            // Placeholder for admin actions
            Wrap(
              spacing: 8.0,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Suspender Plano')),
                ElevatedButton(onPressed: () {}, child: const Text('Reativar Plano')),
                ElevatedButton(onPressed: () {}, child: const Text('Enviar Link de Pagamento')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
