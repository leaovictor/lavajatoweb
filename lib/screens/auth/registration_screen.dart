import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lavajato/services/auth_service.dart';
import 'package:lavajato/services/firestore_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // App Logo/Title
                      Icon(
                        Icons.local_car_wash,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Crie sua conta',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 48),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Por favor, insira um email válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.length < 10) {
                            return 'Por favor, insira um telefone válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Button
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  final authService = AuthService();
                                  try {
                                    final userCredential = await authService
                                        .signUpWithEmailPassword(
                                      _nameController.text,
                                      _emailController.text,
                                      _phoneController.text,
                                      _passwordController.text,
                                    );
                                    if (userCredential != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Cadastro realizado com sucesso!'),
                                        ),
                                      );
                                      // AuthGate will handle navigation
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    String message;
                                    if (e.code == 'weak-password') {
                                      message =
                                          'A senha fornecida é muito fraca.';
                                    } else if (e.code == 'email-already-in-use') {
                                      message =
                                          'O email fornecido já está em uso.';
                                    } else {
                                      message =
                                          'Ocorreu um erro ao fazer o cadastro.';
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Não foi possível fazer o cadastro. Verifique os dados e tente novamente.'),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cadastrar'),
                      ),
                      const SizedBox(height: 16),

                      // Login Button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Já tem uma conta? Entre'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
