import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavajato/models/car_model.dart';
import 'package:lavajato/screens/profile/add_car_screen.dart';
import 'package:lavajato/services/firestore_service.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(
        child: Text('Faça login para ver seus carros.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Carros'),
      ),
      body: StreamBuilder<List<Car>>(
        stream: _firestoreService.getCars(_user!.uid),
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
              builder: (context) => const AddCarScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
