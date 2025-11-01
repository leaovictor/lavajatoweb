import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lavajato/models/service_model.dart';
import 'package:lavajato/screens/home/appointment_screen.dart';
import 'package:lavajato/services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getServices(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Algo deu errado.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum serviço encontrado.'));
        }

        final services = snapshot.data!.docs
            .map((doc) => Service.fromFirestore(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${service.description}\nDuração: ${service.duration} min'),
                trailing: Text(
                  'R\$ ${service.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentScreen(service: service),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
