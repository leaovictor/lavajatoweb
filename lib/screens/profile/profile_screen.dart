import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/screens/subscription/subscription_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: StreamBuilder<UserEntity?>(
        stream: authRepository.user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Usuário não encontrado.'));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Informações Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Nome: ${user.name ?? 'Não informado'}'),
                const SizedBox(height: 8),
                Text('Email: ${user.email}'),
                const SizedBox(height: 32),
                const Text('Minha Assinatura', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSubscriptionInfo(context, user),
                const SizedBox(height: 32),
                const Text('Meus Veículos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Placeholder for car list
                const Expanded(
                  child: Center(
                    child: Text('Nenhum veículo cadastrado.'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to add car screen
                    },
                    child: const Text('Adicionar Veículo'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionInfo(BuildContext context, UserEntity user) {
    if (user.subscription == null || user.subscription!.status != 'active') {
      return Center(
        child: Column(
          children: [
            const Text('Você não tem uma assinatura ativa.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                );
              },
              child: const Text('Ver Planos'),
            ),
          ],
        ),
      );
    } else {
      final subscription = user.subscription!;
      final formattedDate = DateFormat('dd/MM/yyyy').format(subscription.currentPeriodEnd);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plano: ${subscription.planId}'), // In a real app, you'd fetch the plan name
          const SizedBox(height: 8),
          Text('Status: ${subscription.status}'),
          const SizedBox(height: 8),
          Text('Válida até: $formattedDate'),
        ],
      );
    }
  }
}
