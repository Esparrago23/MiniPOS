import 'package:app_prueba/core/di/app_dependencies.dart';
import 'package:app_prueba/core/hardware/camera/barcode_scanner_service.dart';
import 'package:app_prueba/core/routes/app_routes.dart';
import 'package:app_prueba/features/auth/presentation/pages/auth_home_page.dart';
import 'package:app_prueba/features/auth/presentation/pages/login_page.dart';
import 'package:app_prueba/features/auth/presentation/pages/register_page.dart';
import 'package:app_prueba/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:app_prueba/features/products/presentation/pages/product_lookup_page.dart';
import 'package:app_prueba/features/products/presentation/pages/products_page.dart';
import 'package:app_prueba/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:app_prueba/shared/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppDependencies _dependencies;

  @override
  void initState() {
    super.initState();
    _dependencies = AppDependencies();
  }

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final theme = MaterialTheme(textTheme);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(
          value: _dependencies.authViewModel,
        ),
        ChangeNotifierProvider<ProductsViewModel>.value(
          value: _dependencies.productsViewModel,
        ),
        Provider<BarcodeScannerService>.value(
          value: _dependencies.hardwareModule.barcodeScannerService,
        ),
      ],
      child: MaterialApp(
        title: 'Punto de Venta',
        darkTheme: theme.dark(),
        theme: theme.light(),
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.home: (_) => const AuthHomePage(),
          AppRoutes.products: (_) => const ProductsPage(),
          AppRoutes.productLookup: (_) => const ProductLookupPage(),
        },
      ),
    );
  }
}
