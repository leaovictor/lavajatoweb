import 'package:flutter/material.dart';
import 'package:lavajato/screens/appointments/my_appointments_screen.dart';
import 'package:lavajato/screens/home/home_screen.dart';
import 'package:lavajato/screens/service/service_registration_screen.dart';
import 'package:lavajato/services/auth_service.dart';
import 'package:lavajato/theme/theme_notifier.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

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
          Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, child) {
              return IconButton(
                icon: Icon(
                  themeNotifier.themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : themeNotifier.themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.brightness_auto,
                ),
                onPressed: () {
                  if (themeNotifier.themeMode == ThemeMode.light) {
                    themeNotifier.setThemeMode(ThemeMode.dark);
                  } else if (themeNotifier.themeMode == ThemeMode.dark) {
                    themeNotifier.setThemeMode(ThemeMode.system);
                  } else {
                    themeNotifier.setThemeMode(ThemeMode.light);
                  }
                },
                tooltip: 'Mudar tema',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 &&
              _authService.currentUser?.email == 'admin@lavajato.com'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServiceRegistrationScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
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
