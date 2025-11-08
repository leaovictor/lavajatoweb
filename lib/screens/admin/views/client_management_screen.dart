import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavajato/blocs/admin/admin_bloc.dart';
import 'package:lavajato/screens/admin/views/client_detail_screen.dart';

class ClientManagementScreen extends StatelessWidget {
  const ClientManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<AdminBloc>()..add(FetchClients()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestão de Clientes e Assinaturas'),
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state.status == AdminStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == AdminStatus.failure) {
              return const Center(child: Text('Failed to load clients'));
            }

            return ListView.builder(
              itemCount: state.clients.length,
              itemBuilder: (context, index) {
                final client = state.clients[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(client.name?.substring(0, 1) ?? ''),
                  ),
                  title: Text(client.name ?? 'Nome não informado'),
                  subtitle: Text(client.subscription?.planName ?? 'Sem plano'),
                  trailing: Chip(
                    label: Text(client.subscription?.status ?? 'Inativo'),
                    backgroundColor: client.subscription?.status == 'active'
                        ? Colors.green
                        : Colors.grey,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClientDetailScreen(client: client),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
