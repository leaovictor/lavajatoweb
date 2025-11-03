import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lavajato/models/appointment_model.dart';
import 'package:lavajato/models/car_model.dart';
import 'package:lavajato/models/client_model.dart';
import 'package:lavajato/models/service_model.dart';
import 'package:lavajato/screens/admin/add_service_screen.dart';
import 'package:lavajato/screens/admin/customer_list_screen.dart';
import 'package:lavajato/screens/admin/edit_plan_screen.dart';
import 'package:lavajato/screens/admin/manage_plans_screen.dart';
import 'package:lavajato/services/firestore_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Agendamentos do Dia'),
            Tab(icon: Icon(Icons.people), text: 'Assinantes Ativos'),
            Tab(icon: Icon(Icons.local_car_wash), text: 'Serviços'),
            Tab(icon: Icon(Icons.star), text: 'Planos'),
            Tab(icon: Icon(Icons.person), text: 'Clientes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DailyAppointmentsView(),
          _ActiveSubscribersView(),
          _ServicesView(),
          const ManagePlansScreen(),
          const CustomerListScreen(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          if (_tabController.index == 2) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddServiceScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          }
          if (_tabController.index == 3) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditPlanScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ActiveSubscribersView extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Client>>(
      stream: _firestoreService.getActiveSubscribers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar assinantes.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum assinante ativo.'));
        }

        final subscribers = snapshot.data!;

        return ListView.builder(
          itemCount: subscribers.length,
          itemBuilder: (context, index) {
            final subscriber = subscribers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(subscriber.name),
                subtitle: Text(subscriber.email),
              ),
            );
          },
        );
      },
    );
  }
}

class _DailyAppointmentsView extends StatefulWidget {
  const _DailyAppointmentsView({Key? key}) : super(key: key);

  @override
  _DailyAppointmentsViewState createState() => _DailyAppointmentsViewState();
}

class _DailyAppointmentsViewState extends State<_DailyAppointmentsView> {
  final FirestoreService _firestoreService = FirestoreService();
  List<DragAndDropList> _lists = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: _firestoreService.getAllAppointmentsForDay(DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar agendamentos.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum agendamento para hoje.'));
        }

        final appointments = snapshot.data!;
        _buildLists(appointments);

        return DragAndDropLists(
          children: _lists,
          onItemReorder: _onItemReorder,
          onListReorder: _onListReorder,
          listPadding: const EdgeInsets.all(8),
          itemDecorationWhileDragging: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          listDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
        );
      },
    );
  }

  void _buildLists(List<Appointment> appointments) {
    final pending = appointments.where((a) => a.status == 'pendente').toList();
    final inProgress = appointments.where((a) => a.status == 'em_andamento').toList();
    final completed = appointments.where((a) => a.status == 'concluido').toList();

    _lists = [
      _buildDragAndDropList('Pendente', pending),
      _buildDragAndDropList('Em Andamento', inProgress),
      _buildDragAndDropList('Concluído', completed),
    ];
  }

  DragAndDropList _buildDragAndDropList(
      String header, List<Appointment> appointments) {
    return DragAndDropList(
      header: Text(header,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: appointments.map((appointment) {
        return DragAndDropItem(
          child: _AppointmentCard(appointment: appointment),
        );
      }).toList(),
    );
  }

  void _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      final movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);

      final appointment = (movedItem.child as _AppointmentCard).appointment;
      final newStatus = _getStatusFromIndex(newListIndex);

      _firestoreService.updateAppointmentStatus(appointment.id, newStatus);
    });
  }

  void _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      final movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);
    });
  }

  String _getStatusFromIndex(int index) {
    switch (index) {
      case 0:
        return 'pendente';
      case 1:
        return 'em_andamento';
      case 2:
        return 'concluido';
      default:
        return 'pendente';
    }
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(appointment.serviceName),
          content: FutureBuilder<Client>(
            future: _firestoreService.getUser(appointment.clienteId).first,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Text('Erro ao carregar dados do cliente.');
              }

              final client = snapshot.data!;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente: ${client.name}'),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Car>>(
                    future: _firestoreService.getCars(client.uid).first,
                    builder: (context, carSnapshot) {
                      if (carSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (carSnapshot.hasError ||
                          !carSnapshot.hasData ||
                          carSnapshot.data!.isEmpty) {
                        return const Text('Nenhum carro cadastrado.');
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: carSnapshot.data!.map((car) {
                          return Text(
                              'Carro: ${car.brand} ${car.model} - ${car.plate}');
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildStatusDropdown(appointment),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusDropdown(Appointment appointment) {
    return DropdownButton<String>(
      value: appointment.status,
      items: ['pendente', 'em_andamento', 'concluido'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          _firestoreService.updateAppointmentStatus(appointment.id, newValue);
          Navigator.of(context).pop();
        }
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(appointment.serviceName),
      subtitle: Text(
          'Cliente: ${appointment.clienteId} - ${DateFormat('HH:mm').format(appointment.hora)}'),
      onTap: () => (context.findAncestorStateOfType<_DailyAppointmentsViewState>())!
          ._showAppointmentDetails(context, appointment),
    );
  }
}

class _ServicesView extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getServices(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar serviços.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum serviço cadastrado.'));
        }

        final services = snapshot.data!.docs
            .map((doc) => Service.fromFirestore(doc))
            .toList();

        return ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(service.name),
                subtitle: Text(service.description),
                trailing: Text('R\$ ${service.price.toStringAsFixed(2)}'),
              ),
            );
          },
        );
      },
    );
  }
}