import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/models/car_model.dart';
import 'package:lavajato/models/client_model.dart';
import 'package:lavajato/screens/profile/add_car_screen.dart';
import 'package:lavajato/services/firestore_service.dart';

class ManageCarsScreen extends StatefulWidget {
  final Client customer;

  const ManageCarsScreen({super.key, required this.customer});

  @override
  State<ManageCarsScreen> createState() => _ManageCarsScreenState();
}

class _ManageCarsScreenState extends State<ManageCarsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carros de ${widget.customer.name}'),
      ),
      body: StreamBuilder<List<Car>>(
        stream: _firestoreService.getCars(widget.customer.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar carros.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum carro cadastrado.'));
          }

          final cars = snapshot.data!;

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('${car.brand} ${car.model}'),
                  subtitle: Text('Placa: ${car.plate} - Cor: ${car.color}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _firestoreService.deleteCar(widget.customer.uid, car.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddCarScreen(uid: widget.customer.uid), // Pass uid to AddCarScreen
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
