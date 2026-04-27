import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/data/repositories/auth_repository.dart';
import 'package:cesizen_mobile/core/network/api_exception.dart';
import 'package:cesizen_mobile/core/models/user_session.dart';
import 'package:cesizen_mobile/features/auth/register_screen.dart';
import 'package:cesizen_mobile/features/auth/reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.session,
    required this.authRepository,
  });

  final UserSession session;
  final AuthRepository authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      appBar: AppBar(title: const Text('Connexion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE3EBE2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Bienvenue !',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Connectez-vous pour accéder à votre espace personnel et suivre vos sessions de respiration guidée.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email requis';
                        }
                        if (!value.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      validator: (value) => (value == null || value.length < 8)
                          ? '8 caractères minimum'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Se connecter'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ResetPasswordScreen(
                            authRepository: widget.authRepository,
                          ),
                        ),
                      ),
                      child: const Text('Mot de passe oublié ?'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RegisterScreen(
                            session: widget.session,
                            authRepository: widget.authRepository,
                          ),
                        ),
                      ),
                      child: const Text('Pas de compte ? Inscription'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await widget.authRepository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      widget.session.loginWithAuthResponse(response);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion réussie.')),
      );
      Navigator.pop(context);
    } on ApiException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
