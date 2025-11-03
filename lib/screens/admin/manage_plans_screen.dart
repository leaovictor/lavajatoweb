import 'package:flutter/material.dart';
import 'package:lavajato/models/plan_model.dart';
import 'package:lavajato/screens/admin/edit_plan_screen.dart';
import 'package:lavajato/services/plan_service.dart';

class ManagePlansScreen extends StatelessWidget {
  const ManagePlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlanService _planService = PlanService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Planos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditPlanScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Plan>>(
        stream: _planService.getPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os planos.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum plano encontrado.'));
          }

          final plans = snapshot.data!;

          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return ListTile(
                title: Text(plan.name),
                subtitle: Text('R\$ ${plan.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPlanScreen(plan: plan),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _planService.deletePlan(plan.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
