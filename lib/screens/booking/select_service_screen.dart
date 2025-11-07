import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavajato/blocs/booking/booking_bloc.dart';
import 'package:lavajato/blocs/service/service_bloc.dart';
import 'package:lavajato/screens/booking/select_vehicle_screen.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';

class SelectServiceScreen extends StatelessWidget {
  const SelectServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Selecione um Serviço'),
        ),
        body: BlocProvider(
          create: (context) => ServiceBloc(
            serviceRepository: context.read<ServiceRepository>(),
          )..add(LoadServices()),
          child: BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              if (state is ServiceLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ServiceError) {
                return Center(child: Text('Erro: ${state.message}'));
              } else if (state is ServiceLoaded) {
                if (state.services.isEmpty) {
                  return const Center(
                      child: Text('Nenhum serviço encontrado.'));
                }
                return ListView.builder(
                  itemCount: state.services.length,
                  itemBuilder: (context, index) {
                    final service = state.services[index];
                    return ListTile(
                      title: Text(service.name),
                      subtitle: Text(
                          'Preço: R\$${service.price.toStringAsFixed(2)} - Duração: ${service.durationInMinutes} min'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context
                            .read<BookingBloc>()
                            .add(ServiceSelected(service));
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: BlocProvider.of<BookingBloc>(context),
                              child: const SelectVehicleScreen(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
              return const Center(child: Text('Selecione um serviço.'));
            },
          ),
        ),
      ),
    );
  }
}
