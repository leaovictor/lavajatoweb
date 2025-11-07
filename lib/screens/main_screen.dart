import 'package:flutter/material.dart';
import 'package:lavajato/screens/appointments/my_appointments_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavajato/blocs/auth/auth_bloc.dart';
import 'package:lavajato/screens/admin/admin_dashboard_screen.dart';
import 'package:lavajato/screens/booking/select_service_screen.dart';
import 'package:lavajato/screens/home/home_screen.dart';
import 'package:lavajato/screens/subscription/subscription_screen.dart';
import 'package:lavajato/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const HomeScreen(),
      const MyAppointmentsScreen(),
      const SubscriptionScreen(),
    ];

    final List<String> titles = <String>[
      'Início',
      'Meus Agendamentos',
      'Assinatura',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState.status == AuthStatus.authenticated && authState.user!.isAdmin) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ));
                  },
                  tooltip: 'Painel Administrativo',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile layout
            return Center(
              child: widgetOptions.elementAt(_selectedIndex),
            );
          } else {
            // Web layout
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Início'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_today),
                      label: Text('Agendamentos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.subscriptions),
                      label: Text('Assinatura'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Center(
                    child: widgetOptions.elementAt(_selectedIndex),
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SelectServiceScreen(),
                  ),
                );
              },
              label: const Text('Novo Agendamento'),
              icon: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Agendamentos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.subscriptions),
                  label: 'Assinatura',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            )
          : null,
    );
  }
}
