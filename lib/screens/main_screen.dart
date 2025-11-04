import 'package:flutter/material.dart';
import 'package:lavajato/data/repositories/auth_repository_impl.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/screens/appointments/my_appointments_screen.dart';
import 'package:lavajato/screens/home/home_screen.dart';
import 'package:lavajato/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthRepository _authRepository = AuthRepositoryImpl();

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
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Serviços' : 'Meus Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            tooltip: 'Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authRepository.signOut();
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
