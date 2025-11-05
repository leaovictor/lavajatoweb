import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lavajato/data/models/user_model.dart';
import 'package:lavajato/data/services/firestore_service.dart';

class ClientsListView extends StatelessWidget {
  const ClientsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar clientes.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum cliente cadastrado.'));
        }

        final users = snapshot.data!.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList();

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  user.name ?? 'Nome não informado',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user.email),
                leading: CircleAvatar(
                  child: Text(user.name?.isNotEmpty == true ? user.name![0] : '?'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
