import 'package:flutter/material.dart';
import 'package:lavajato/screens/booking/select_date_time_screen.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';

class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen({super.key});

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  late Future<List<ServiceEntity>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    final serviceRepository =
        Provider.of<ServiceRepository>(context, listen: false);
    _servicesFuture = serviceRepository.getServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione um Serviço'),
      ),
      body: FutureBuilder<List<ServiceEntity>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum serviço encontrado.'));
          }

          final services = snapshot.data!;
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                title: Text(service.name),
                subtitle: Text(
                    'Preço: R\$${service.price.toStringAsFixed(2)} - Duração: ${service.durationInMinutes} min'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SelectDateTimeScreen(service: service),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
