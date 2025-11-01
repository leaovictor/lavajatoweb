import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lavajato/services/firestore_service.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos de Assinatura'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSubscriptionCard(
            context,
            title: 'Plano Básico',
            price: 'R\$ 29,90/mês',
            features: [
              '1 lavagem simples por mês',
              'Acesso a agendamentos online',
            ],
            onTap: () => _handleSubscription(context, 'basic'),
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context,
            title: 'Plano Premium',
            price: 'R\$ 59,90/mês',
            features: [
              '2 lavagens completas por mês',
              'Enceramento incluso',
              'Acesso prioritário a agendamentos',
            ],
            onTap: () => _handleSubscription(context, 'premium'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscription(BuildContext context, String plan) async {
    // ATENÇÃO: A implementação a seguir é uma SIMULAÇÃO.
    // Em um aplicativo de produção, o `clientSecret` da intenção de pagamento
    // deve ser buscado de um backend seguro. Não deve ser fixo no código.
    // O backend seria responsável por se comunicar com a API da Stripe
    // para criar a intenção de pagamento e retornar o `clientSecret` para o app.

    // 1. Create a payment intent (simulated backend call)
    final clientSecret =
        'pi_3JgQYgF1a1a1a1a1a1a1a1a1_secret_a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1';

    try {
      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'LavaJato App',
        ),
      );

      // 3. Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pagamento concluído com sucesso!')),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirestoreService()
            .updateUserSubscriptionStatus(user.uid, 'active');
      }
    } on Exception catch (e) {
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro do Stripe: ${e.error.localizedMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro: $e')),
        );
      }
    }
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required VoidCallback onTap,
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
                child: const Text('Assinar Agora'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
