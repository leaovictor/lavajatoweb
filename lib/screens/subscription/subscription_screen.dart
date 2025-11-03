import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lavajato/services/firestore_service.dart';
import 'package:lavajato/services/mercadopago_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final MercadoPagoService _mercadoPagoService = MercadoPagoService();
  bool _isProcessing = false;

  Future<void> _handleSubscription(BuildContext context, String plan) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final preference = await _mercadoPagoService.createPreference(plan);
      final checkoutUrl = preference['checkoutUrl'];

      final uri = Uri.parse(checkoutUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        if (mounted) {
          _showPaymentSimulationDialog(context, plan);
        }
      } else {
        throw 'Could not launch $checkoutUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onPaymentSuccess(BuildContext context, String plan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirestoreService()
          .updateUserSubscriptionStatus(user.uid, 'active', plan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pagamento concluído e assinatura ativada!')),
        );
      }
    }
  }

  void _showPaymentSimulationDialog(BuildContext context, String plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Simulação de Pagamento'),
          content: const Text('Você foi redirecionado para o Mercado Pago. Após concluir, confirme se o pagamento foi aprovado.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pagamento cancelado.')),
                  );
                }
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _onPaymentSuccess(context, plan);
              },
              child: const Text('Aprovado'),
            ),
          ],
        );
      },
    );
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
            onTap: _isProcessing ? null : () => _handleSubscription(context, 'basic'),
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
            onTap: _isProcessing ? null : () => _handleSubscription(context, 'premium'),
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
    required VoidCallback? onTap,
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
                  : const Text('Assinar Agora'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
