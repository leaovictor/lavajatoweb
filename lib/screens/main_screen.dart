import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lavajato/screens/admin/add_service_screen.dart';
import 'package:lavajato/screens/appointments/my_appointments_screen.dart';
import 'package:lavajato/screens/home/home_screen.dart';
import 'package:lavajato/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final user = FirebaseAuth.instance.currentUser;

  // For demonstration purposes, we'll hardcode the admin email.
  // In a real app, this would be handled with custom claims or a roles collection.
  bool get _isAdmin => user?.email == 'admin@lavajato.com';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddService() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddServiceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const HomeScreen(),
      const MyAppointmentsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Serviços' : 'Meus Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
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
                      label: Text('Serviços'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_today),
                      label: Text('Agendamentos'),
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
      floatingActionButton: _isAdmin && _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateToAddService,
              tooltip: 'Adicionar Serviço',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Serviços',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Agendamentos',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            )
          : null,
    );
  }
}
