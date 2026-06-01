import 'package:app_prueba/core/routes/app_routes.dart';
import 'package:app_prueba/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthHomePage extends StatelessWidget {
  const AuthHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final user = viewModel.session?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MiniPOS'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    await context.read<AuthViewModel>().logout();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.login);
                    }
                  },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.point_of_sale,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Sesion iniciada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                user == null
                    ? 'Usuario autenticado'
                    : '${user.name}\n${user.email}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
