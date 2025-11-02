
import 'package:flutter/material.dart';

import 'package:lavajato/screens/auth/registration_screen.dart';
import 'package:lavajato/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'Bem-vindo ao LavaJato',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 48),

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
                          if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Por favor, insira um email válido.';
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
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            final authResult = await _authService.signInWithEmailPassword(
                              _emailController.text,
                              _passwordController.text,
                            );
                            if (authResult.errorMessage != null) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authResult.errorMessage!),
                                ),
                              );
                            }
                            setState(() {
                              _isLoading = false;
                            });
                            // AuthGate will handle navigation
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Entrar'),
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showPasswordResetDialog(),
                          child: const Text('Esqueceu a senha?'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Sign Up Button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ));
                        },
                        child: const Text('Não tem uma conta? Cadastre-se'),
                      ),

                      const SizedBox(height: 24),
                      // Divider
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('OU'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Google Sign-In Button
                      // ElevatedButton.icon(
                      //   onPressed: _signInWithGoogle,
                      //   icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                      //   label: const Text('Entrar com Google'),
                      //   style: ElevatedButton.styleFrom(
                      //     foregroundColor: Colors.white,
                      //     backgroundColor: Colors.red,
                      //     padding: const EdgeInsets.symmetric(vertical: 12),
                      //   ),
                      // ),
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
      ]),
  );}

  void _showPasswordResetDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redefinir senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Digite seu email para receber um link de redefinição de senha.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                _authService.sendPasswordResetEmail(emailController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Se o email estiver correto, um link para redefinir a senha será enviado.'),
                  ),
                );
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
