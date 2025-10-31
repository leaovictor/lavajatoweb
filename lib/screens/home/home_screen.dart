import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lavajato/models/service_model.dart';
import 'package:lavajato/screens/scheduling/scheduling_screen.dart';
import 'package:lavajato/services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar serviços.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum serviço disponível.'));
        }

        final services = snapshot.data!.docs
            .map((doc) => Service.fromFirestore(doc))
            .toList();

        return ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ListTile(
              title: Text(service.name),
              subtitle: Text(
                  '${service.description}\nPreço: R\$${service.price.toStringAsFixed(2)} - Duração: ${service.duration} min'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SchedulingScreen(service: service),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
