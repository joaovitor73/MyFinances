import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_finances/ui/pages/despesas_screen.dart';
import 'package:my_finances/ui/pages/home.dart';
import 'package:provider/provider.dart';
import 'package:my_finances/core/configure_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("Conexão com o Firebase bem-sucedida!");
  } catch (e) {
    print("Erro ao conectar com o Firebase: $e");
  }
  final configureProviders = await ConfigureProviders.createDependencyTree();
  runApp(
    MultiProvider(
      providers: configureProviders.providers,
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/list_despesas': (context) => const DespesasScreen(),
      },
    );
  }
}
