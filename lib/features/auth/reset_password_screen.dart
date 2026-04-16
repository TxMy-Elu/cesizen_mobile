import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/data/repositories/auth_repository.dart';
import 'package:cesizen_mobile/core/network/api_exception.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPassword = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset mot de passe')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email compte'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _tokenController,
                    decoration: const InputDecoration(labelText: 'Token de reinitialisation'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _newPassword,
                    decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _isLoading ? null : _requestResetLink,
                        child: const Text('Envoyer le lien'),
                      ),
                      OutlinedButton(
                        onPressed: _isLoading ? null : _validateToken,
                        child: const Text('Verifier le token'),
                      ),
                      FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Reinitialiser'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email invalide.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.authRepository.forgotPassword(email);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Si le compte existe, un lien a ete envoye.')),
      );
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

  Future<void> _validateToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Token requis.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final valid = await widget.authRepository.validateResetToken(token);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(valid ? 'Token valide.' : 'Token invalide ou expiré.')),
      );
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

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email invalide.')));
      return;
    }
    if (token.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Token requis.')));
      return;
    }
    if (_newPassword.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe trop court.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.authRepository.resetPassword(
        token: token,
        newPassword: _newPassword.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe reinitialise avec succes.')),
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
