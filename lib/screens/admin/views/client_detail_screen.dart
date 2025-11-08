import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavajato/blocs/admin/admin_bloc.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:intl/intl.dart';

class ClientDetailScreen extends StatelessWidget {
  final UserEntity client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<AdminBloc>()..add(FetchClientDetails(client.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(client.name ?? 'Detalhes do Cliente'),
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state.status == AdminStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == AdminStatus.failure) {
              return const Center(child: Text('Failed to load client details'));
            }

            final selectedClient = state.selectedClient;

            if (selectedClient == null) {
              return const Center(child: Text('Client not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Histórico de Pagamentos', style: Theme.of(context).textTheme.titleLarge),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.paymentHistory.length,
                    itemBuilder: (context, index) {
                      final payment = state.paymentHistory[index];
                      return ListTile(
                        leading: const Icon(Icons.payment),
                        title: Text('R\$ ${payment.amount.toStringAsFixed(2)}'),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(payment.date)),
                        trailing: Text(payment.status),
                      );
                    },
                  ),
                  const Divider(),
                  Text('Histórico de Serviços', style: Theme.of(context).textTheme.titleLarge),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.serviceHistory.length,
                    itemBuilder: (context, index) {
                      final service = state.serviceHistory[index];
                      return ListTile(
                        leading: const Icon(Icons.local_car_wash),
                        title: Text(service.serviceName),
                        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(service.startTime)),
                        trailing: Text(service.status),
                      );
                    },
                  ),
                  const Divider(),
                  Text('Ações do Admin', style: Theme.of(context).textTheme.titleLarge),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<AdminBloc>().add(SuspendSubscription(selectedClient.subscription!.subscriptionId!));
                        },
                        child: const Text('Suspender Plano'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AdminBloc>().add(ReactivateSubscription(selectedClient.subscription!.subscriptionId!));
                        },
                        child: const Text('Reativar Plano'),
                      ),
                      ElevatedButton(
                        onPressed: null, // Disabled for now
                        child: const Text('Enviar Link de Pagamento'),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
