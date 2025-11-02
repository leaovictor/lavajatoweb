import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:lavajato/services/firestore_service.dart';
import 'package:lavajato/stripe_keys.dart';

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
  
      Future<void> _handleSubscription(BuildContext context, String plan) async {
        // ATENÇÃO: A implementação a seguir é uma SIMULAÇÃO.
        // Em um aplicativo de produção, o `clientSecret` da intenção de pagamento
        // deve ser buscado de um backend seguro. Não deve ser fixo no código.
    
        // Para a Web, a Payment Sheet não é suportada. Simula um pagamento bem-sucedido.
        if (kIsWeb) {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await FirestoreService()
                  .updateUserSubscriptionStatus(user.uid, 'active', plan);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Assinatura (simulada) ativada com sucesso!')),
              );
            }
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ocorreu um erro ao simular o pagamento: $e')),
            );
          }
          return;
        }
    
        // Lógica para Mobile (iOS/Android)
        try {
          final paymentIntent = await _createPaymentIntent(plan);
          if (paymentIntent == null || paymentIntent['clientSecret'] == null) {
            throw Exception('Falha ao criar a intenção de pagamento.');
          }

          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent['clientSecret'],
              merchantDisplayName: 'LavaJato App',
            ),
          );
    
          await Stripe.instance.presentPaymentSheet();
    
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirestoreService()
                .updateUserSubscriptionStatus(user.uid, 'active', plan);
          }

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pagamento concluído com sucesso!')),
          );
        } on Exception catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ocorreu um erro: ${e.toString()}')),
          );
        }
      }
    
      // Simulated backend function
      Future<Map<String, dynamic>?> _createPaymentIntent(String plan) async {
        // Em um app real, isso seria uma chamada de rede para o seu backend.
        final Map<String, int> prices = {
          'basic': 2990, // R$ 29,90
          'premium': 5990, // R$ 59,90
        };
    
        final amount = prices[plan];
        if (amount == null) return null;
    
        // Retorna o segredo do cliente de teste para a simulação no celular.
        return {
          'clientSecret': paymentIntentClientSecret,
          'amount': amount,
        };
      }
    }
