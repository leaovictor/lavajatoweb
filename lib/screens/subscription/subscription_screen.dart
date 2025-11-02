import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:lavajato/services/firestore_service.dart';
import 'package:lavajato/stripe_keys.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // Controller para o campo de cartão de crédito na web
  final controller = CardEditController();

  // Função principal que orquestra o fluxo de pagamento
  Future<void> _handleSubscription(BuildContext context, String plan) async {
    try {
      // 1. (SIMULADO) Cria a intenção de pagamento no backend
      final paymentIntent = await _createPaymentIntent(plan);
      final clientSecret = paymentIntent?['clientSecret'];

      if (clientSecret == null) {
        throw Exception('Falha ao criar a intenção de pagamento.');
      }

      // 2. Executa o fluxo de pagamento específico da plataforma
      if (kIsWeb) {
        await _handleWebAppPayment(context, clientSecret, plan);
      } else {
        await _handleMobileAppPayment(context, clientSecret, plan);
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro: ${e.toString()}')),
      );
    }
  }

  // Lida com o pagamento na plataforma Web
  Future<void> _handleWebAppPayment(
      BuildContext context, String clientSecret, String plan) async {
    // Exibe um diálogo com o formulário de cartão
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Pagamento via Web (Simulado)'),
          content: CardField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Dados do Cartão',
              hintText: 'Use o cartão de teste 4242...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.complete) {
                  // 3. Confirma o pagamento com os dados do cartão
                  await Stripe.instance.confirmPayment(
                    paymentIntentClientSecret: clientSecret,
                    data: const PaymentMethodParams.card(
                      paymentMethodData: PaymentMethodData(),
                    ),
                  );
                  await _onPaymentSuccess(context, plan);
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor, preencha os dados do cartão.')),
                  );
                }
              },
              child: const Text('Pagar'),
            ),
          ],
        );
      },
    );
  }

  // Lida com o pagamento na plataforma Mobile
  Future<void> _handleMobileAppPayment(
      BuildContext context, String clientSecret, String plan) async {
    // 2. Inicializa a Payment Sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'LavaJato App',
      ),
    );

    // 3. Apresenta a Payment Sheet
    await Stripe.instance.presentPaymentSheet();

    // 4. Se o pagamento for concluído com sucesso, atualiza o status do usuário
    await _onPaymentSuccess(context, plan);
  }

  // Função chamada após um pagamento bem-sucedido (real ou simulado)
  Future<void> _onPaymentSuccess(BuildContext context, String plan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirestoreService()
          .updateUserSubscriptionStatus(user.uid, 'active', plan);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pagamento concluído e assinatura ativada!')),
      );
    }
  }

  // (SIMULADO) Função que representa a chamada ao seu backend
  Future<Map<String, dynamic>?> _createPaymentIntent(String plan) async {
    final Map<String, int> prices = {
      'basic': 2990,
      'premium': 5990,
    };
    final amount = prices[plan];
    if (amount == null) return null;

    return {
      'clientSecret': paymentIntentClientSecret,
      'amount': amount,
    };
  }

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
            context: context,
            title: 'Plano Básico',
            price: 'R\$ 29,90/mês',
            features: const [
              '1 lavagem simples por mês',
              'Acesso a agendamentos online',
            ],
            onTap: () => _handleSubscription(context, 'basic'),
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context: context,
            title: 'Plano Premium',
            price: 'R\$ 59,90/mês',
            features: const [
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

  Widget _buildSubscriptionCard({
    required BuildContext context,
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
