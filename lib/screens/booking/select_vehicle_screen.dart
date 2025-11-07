import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavajato/blocs/booking/booking_bloc.dart';
import 'package:lavajato/blocs/vehicle/vehicle_bloc.dart';
import 'package:lavajato/domain/repositories/vehicle_repository.dart';
import 'package:lavajato/screens/booking/select_date_time_screen.dart';
import 'package:lavajato/widgets/add_vehicle_form.dart';

class SelectVehicleScreen extends StatelessWidget {
  const SelectVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione um Veículo'),
      ),
      body: BlocProvider(
        create: (context) => VehicleBloc(
          vehicleRepository: context.read<VehicleRepository>(),
        )..add(LoadVehicles()),
        child: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VehicleError) {
              return Center(child: Text('Erro: ${state.message}'));
            } else if (state is VehicleLoaded) {
              if (state.vehicles.isEmpty) {
                return const Center(child: Text('Nenhum veículo encontrado.'));
              }
              return ListView.builder(
                itemCount: state.vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = state.vehicles[index];
                  return ListTile(
                    title: Text('${vehicle.make} ${vehicle.model}'),
                    subtitle: Text(vehicle.licensePlate),
                    onTap: () {
                      context.read<BookingBloc>().add(VehicleSelected(vehicle));
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: BlocProvider.of<BookingBloc>(context),
                            child: const SelectDateTimeScreen(),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const Center(child: Text('Selecione um veículo.'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => BlocProvider.value(
              value: BlocProvider.of<VehicleBloc>(context),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: AddVehicleForm(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
