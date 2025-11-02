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
      // Em um app real, esta função faria uma chamada de rede para o seu servidor.
      // O servidor, usando a chave SECRETA do Stripe, criaria uma PaymentIntent
      // e retornaria o clientSecret para o app.
      final paymentIntent = await _createPaymentIntent(plan);
      final clientSecret = paymentIntent?['clientSecret'];

      if (clientSecret == null) {
        throw Exception('Falha ao criar a intenção de pagamento.');
      }

      // 2. Executa o fluxo de pagamento específico da plataforma
      if (kIsWeb) {
        // Para a Web, usamos o CardField, pois a PaymentSheet não é suportada.
        await _handleWebAppPayment(context, clientSecret, plan);
      } else {
        // Para Mobile (iOS/Android), usamos a PaymentSheet para uma melhor UX.
        await _handleMobileAppPayment(context, clientSecret, plan);
      }
    } on Exception catch (e) {
      if (!context.mounted) return;
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
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
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
                  // 3. (SIMULADO) Confirma o pagamento com os dados do cartão
                  // Em um app real, você chamaria `Stripe.instance.confirmPayment`
                  // para finalizar a transação. Aqui, simulamos o sucesso.
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
    // Em um app real, aqui você faria uma chamada HTTP (POST) para o seu servidor.
    // O servidor se comunicaria com a API da Stripe para criar uma PaymentIntent
    // com o valor correto e retornaria o `clientSecret`.
    final Map<String, int> prices = {
      'basic': 2990,
      'premium': 5990,
    };
    final amount = prices[plan];
    if (amount == null) return null;

    // Retornamos o `paymentIntentClientSecret` de teste do arquivo `stripe_keys.dart`.
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
