import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavajato/blocs/admin/admin_bloc.dart';
import 'package:lavajato/screens/admin/views/client_management_screen.dart';
import 'package:lavajato/screens/admin/widgets/dashboard_card.dart';
import 'package:lavajato/screens/admin/widgets/management_module_card.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          context.read<AdminBloc>()..add(FetchDashboardData()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state.status == AdminStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == AdminStatus.failure) {
              return const Center(child: Text('Failed to load dashboard data'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DashboardCard(
                        title: 'MRR',
                        value: 'R\$ ${state.mrr.toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                      ),
                      DashboardCard(
                        title: 'Novas Assinaturas',
                        value: state.newSubscriptions.toString(),
                        icon: Icons.new_releases,
                      ),
                      DashboardCard(
                        title: 'Churn',
                        value: state.churn.toString(),
                        icon: Icons.trending_down,
                      ),
                      DashboardCard(
                        title: 'Clientes Ativos',
                        value: state.activeClients.toString(),
                        icon: Icons.people,
                      ),
                      DashboardCard(
                        title: 'Agendamentos (Hoje)',
                        value: state.todayAppointments.toString(),
                        icon: Icons.calendar_today,
                      ),
                      DashboardCard(
                        title: 'Faturamento Adicional',
                        value: 'R\$ ${state.additionalRevenue.toStringAsFixed(2)}',
                        icon: Icons.add_shopping_cart,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Módulos de Gestão',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ManagementModuleCard(
                        title: 'Gestão de Assinaturas e Clientes',
                        icon: Icons.subscriptions,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ClientManagementScreen(),
                            ),
                          );
                        },
                      ),
                      // ... other management modules
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
