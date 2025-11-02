import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lavajato/screens/admin/admin_dashboard_screen.dart';
import 'package:lavajato/screens/appointments/my_appointments_screen.dart';
import 'package:lavajato/screens/auth/login_screen.dart';
import 'package:lavajato/screens/home/home_screen.dart';
import 'package:lavajato/screens/profile/my_cars_screen.dart';
import 'package:lavajato/screens/subscription/subscription_screen.dart';
import 'package:lavajato/services/auth_service.dart';

import 'package:lavajato/models/client_model.dart';
import 'package:lavajato/services/firestore_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const LoginScreen();
    }

    return StreamBuilder<Client>(
      stream: _firestoreService.getUser(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Erro ao carregar dados do usuário.'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: Text('Usuário não encontrado.'),
            ),
          );
        }

        final client = snapshot.data!;
        final bool _isAdmin = client.rule == 'admin';

        final List<Widget> widgetOptions = <Widget>[
          const HomeScreen(),
          const MyAppointmentsScreen(),
          const MyCarsScreen(),
          const SubscriptionScreen(),
          if (_isAdmin) const AdminDashboardScreen(),
        ];

        if (_selectedIndex >= widgetOptions.length) {
          _selectedIndex = 0;
        }

        final List<String> titles = [
          'Serviços',
          'Meus Agendamentos',
          'Meus Carros',
          'Assinatura',
          if (_isAdmin) 'Admin',
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(titles[_selectedIndex]),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _authService.signOut().then((_) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  });
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
                      destinations: <NavigationRailDestination>[
                        const NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Serviços'),
                        ),
                        const NavigationRailDestination(
                          icon: Icon(Icons.calendar_today),
                          label: Text('Agendamentos'),
                        ),
                        const NavigationRailDestination(
                          icon: Icon(Icons.directions_car),
                          label: Text('Meus Carros'),
                        ),
                        const NavigationRailDestination(
                          icon: Icon(Icons.star),
                          label: Text('Assinatura'),
                        ),
                        if (_isAdmin)
                          const NavigationRailDestination(
                            icon: Icon(Icons.admin_panel_settings),
                            label: Text('Admin'),
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
          bottomNavigationBar: MediaQuery.of(context).size.width < 600
              ? BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  items: <BottomNavigationBarItem>[
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Serviços',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today),
                      label: 'Agendamentos',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.directions_car),
                      label: 'Meus Carros',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.star),
                      label: 'Assinatura',
                    ),
                    if (_isAdmin)
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.admin_panel_settings),
                        label: 'Admin',
                      ),
                  ],
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                )
              : null,
        );
      },
    );
  }
}
