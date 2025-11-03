import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/models/client_model.dart';
import 'package:lavajato/models/plan_model.dart';
import 'package:lavajato/services/firestore_service.dart';
import 'package:lavajato/services/plan_service.dart';
import 'package:lavajato/services/stripe_service.dart';


class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final StripeService _stripeService = StripeService();
  final FirestoreService _firestoreService = FirestoreService();
  final PlanService _planService = PlanService();
  final bool _isProcessing = false;

  Future<void> _handleSubscription(Plan plan) async {
    try {
      // Ensure user is authenticated and refresh token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você precisa estar logado para assinar um plano.')),
        );
        return;
      }
      await user.getIdToken(true); // Force refresh of ID token

      await _stripeService.createCheckoutSessionAndRedirect(
        planId: plan.id,
        successUrl: 'https://lavajato-5944c.firebaseapp.com/payment/success',
        cancelUrl: 'https://lavajato-5944c.firebaseapp.com/payment/failure',
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Ocorreu um erro inesperado.';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuário não autenticado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Assinatura'),
      ),
      body: StreamBuilder<Client>(
        stream: _firestoreService.getUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Usuário não encontrado.'));
          }

          final client = snapshot.data!;

          if (client.subscriptionStatus == 'active') {
            return _buildActiveSubscriptionView(client);
          } else {
            return _buildInactiveSubscriptionView();
          }
        },
      ),
    );
  }

  Widget _buildActiveSubscriptionView(Client client) {
    final expirationDate = client.subscriptionDate?.add(const Duration(days: 30));
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plano Ativo', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Plano'),
                    trailing: Text(
                      client.subscriptionPlan ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: const Text('Data de Adesão'),
                    trailing: Text(
                      client.subscriptionDate != null
                          ? dateFormat.format(client.subscriptionDate!)
                          : 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: const Text('Vencimento'),
                    trailing: Text(
                      expirationDate != null
                          ? dateFormat.format(expirationDate)
                          : 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Gerenciar Plano', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildPlanList(client),
        ],
      ),
    );
  }

  Widget _buildInactiveSubscriptionView() {
    return _buildPlanList(null);
  }

  Widget _buildPlanList(Client? client) {
    return StreamBuilder<List<Plan>>(
      stream: _planService.getPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar os planos.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum plano disponível.'));
        }

        final plans = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            final bool isCurrentPlan = client?.subscriptionPlan == plan.name;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildSubscriptionCard(
                context: context,
                title: plan.name,
                price: 'R\$ ${plan.price.toStringAsFixed(2)}/mês',
                features: plan.features,
                onTap: isCurrentPlan ? null : () => _handleSubscription(plan),
                buttonText: isCurrentPlan
                    ? 'Plano Atual'
                    : client == null
                        ? 'Assinar Agora'
                        : 'Trocar de Plano',
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubscriptionCard({
    required BuildContext context,
    required String title,
    required String price,
    required List<String> features,
    required VoidCallback? onTap,
    required String buttonText,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const Divider(height: 24),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
