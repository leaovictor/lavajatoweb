import 'package:flutter/material.dart';
import 'package:lavajato/screens/admin/clients_list_view.dart';
import 'package:lavajato/screens/admin/daily_appointments_view.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Administrativo'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'Agendamentos do Dia'),
              Tab(icon: Icon(Icons.people), text: 'Clientes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DailyAppointmentsView(),
            ClientsListView(),
          ],
        ),
      ),
    );
  }
}
