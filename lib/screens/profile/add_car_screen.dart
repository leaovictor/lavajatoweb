import 'package:flutter/material.dart';
import 'package:lavajato/domain/entities/car_entity.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

class AddCarScreen extends StatefulWidget {
  final String userId;
  const AddCarScreen({super.key, required this.userId});

  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final authRepository = Provider.of<AuthRepository>(context, listen: false);

    final car = CarEntity(
      id: '', // Firestore will generate this
      brand: _brandController.text,
      model: _modelController.text,
      licensePlate: _licensePlateController.text,
    );

    try {
      await authRepository.addCar(widget.userId, car);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veículo adicionado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar veículo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Veículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira la marca do veículo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o modelo do veículo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a placa do veículo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _saveCar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Salvar Veículo'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
