import 'package:flutter/material.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  final AuthViewModel viewModel;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onRegisterTap;

  const LoginPage({
    super.key,
    required this.viewModel,
    this.onLoginSuccess,
    this.onRegisterTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await widget.viewModel.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted || !success) {
      return;
    }

    widget.onLoginSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedBuilder(
              animation: widget.viewModel,
              builder: (context, _) {
                return Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Iniciar sesion',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Accede al punto de venta.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      AuthTextField(
                        controller: _emailController,
                        label: 'Correo electronico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Contrasena',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: _requiredValidator,
                      ),
                      if (widget.viewModel.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          widget.viewModel.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: widget.viewModel.isLoading ? null : _submit,
                        child: widget.viewModel.isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                      TextButton(
                        onPressed: widget.viewModel.isLoading
                            ? null
                            : widget.onRegisterTap,
                        child: const Text('Crear cuenta'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }
    return null;
  }
}
