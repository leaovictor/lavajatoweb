import 'package:flutter/material.dart';
import 'package:lavajato/domain/entities/car_entity.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/screens/profile/add_car_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthRepository _authRepository;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  UserEntity? _currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authRepository = Provider.of<AuthRepository>(context, listen: false);
  }

  void _updateControllers(UserEntity user) {
    if (_currentUser?.id != user.id) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _currentUser = user;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(String userId) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authRepository.updateUserProfile(
          userId,
          _nameController.text,
          _phoneController.text,
          _addressController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso!')),
          );
        }
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar o perfil: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing && _currentUser != null) {
                _updateProfile(_currentUser!.id);
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            tooltip: _isEditing ? 'Salvar' : 'Editar',
          ),
        ],
      ),
      body: StreamBuilder<UserEntity?>(
        stream: _authRepository.user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Usuário não encontrado.'));
          }

          final user = snapshot.data!;
          _updateControllers(user);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informações Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'Endereço', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 32),
                  const Text('Meus Veículos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildCarList(user.id),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AddCarScreen(userId: user.id),
                        ));
                      },
                      child: const Text('Adicionar Veículo'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarList(String userId) {
    return StreamBuilder<List<CarEntity>>(
      stream: _authRepository.getCars(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar veículos.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Nenhum veículo cadastrado.'),
            ),
          );
        }

        final cars = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text('${car.brand} ${car.model}'),
                subtitle: Text(car.licensePlate),
              ),
            );
          },
        );
      },
    );
  }
}
