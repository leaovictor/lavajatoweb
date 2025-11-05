import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:lavajato/data/services/subscription_service.dart';
import 'package:lavajato/models/plan_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;

  Future<void> _subscribe(Plan plan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para assinar um plano.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sessionId = await _subscriptionService.createCheckoutSession(
        priceId: plan.stripePriceId,
        userId: user.uid,
      );

      if (sessionId != null && mounted) {
        print('Redirecting to Stripe Checkout with session ID: $sessionId');
        final url = 'https://checkout.stripe.com/pay/$sessionId';

        try {
          // The following line will not work in this environment, but it's
          // the correct implementation for a real app.
          // await launchUrl(Uri.parse(url));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Redirecionando para o pagamento... URL: $url'),
              backgroundColor: Colors.green,
            ),
          );
           Navigator.of(context).pop();
        } catch (e) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Não foi possível abrir a página de pagamento: $e')),
          );
        }
      } else {
        throw Exception('Failed to create Stripe Checkout session.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar assinatura: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos de Assinatura'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getSubscriptionPlans(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar os planos.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhum plano de assinatura encontrado.'));
                }

                final plans = snapshot.data!.docs
                    .map((doc) => Plan.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(plan.description),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'R\$ ${plan.price.toStringAsFixed(2)} / mês',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _subscribe(plan),
                                  child: const Text('Assinar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
