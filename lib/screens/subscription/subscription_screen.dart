import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:lavajato/models/plan_model.dart';
import 'package:lavajato/data/repositories/plan_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/services/auth_service.dart';
import 'package:lavajato/models/user_model.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PlanRepositoryImpl _planRepository =
      PlanRepositoryImpl(FirebaseFirestore.instance);
  final AuthService _authService = AuthService();
  late Future<List<Plan>> _plansFuture;
  late Stream<UserModel?> _userStream;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _plansFuture = _planRepository.getPlans();
    _userStream = _authService.user;
  }

  Future<void> _subscribeToPlan(Plan plan, String userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // IMPORTANT: Replace with your Cloud Function URL
      final url = Uri.parse(
          'https://us-central1-lavajato-5944c.cloudfunctions.net/createSubscriptionCheckoutSession');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'priceId': plan.stripePriceId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final session = json.decode(response.body);
        await Stripe.instance.redirectToCheckout(
          checkoutUrl: session['url'],
          sessionId: session['id'],
        );
      } else {
        throw Exception('Failed to create checkout session: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar a assinatura: $e')),
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
      body: StreamBuilder<UserModel?>(
        stream: _userStream,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return const Center(
                child: Text('Erro ao carregar dados do usuário.'));
          }
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Usuário não encontrado.'));
          }

          final user = userSnapshot.data!;
          final subscriptionStatus = user.subscriptionStatus ?? 'Nenhuma';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Sua assinatura: $subscriptionStatus',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Plan>>(
                  future: _plansFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Erro ao carregar os planos.'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Nenhum plano disponível.'));
                    }
                    final plans = snapshot.data!;
                    return ListView.builder(
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: ListTile(
                            title: Text(plan.name),
                            subtitle: Text(
                                '${plan.description}\nR\$ ${plan.price.toStringAsFixed(2)}/mês'),
                            trailing: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _subscribeToPlan(plan, user.uid),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Assinar'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
