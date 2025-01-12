import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_finances/ui/pages/home.dart';
import 'package:provider/provider.dart';
import 'package:my_finances/core/configure_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // final configureProviders = await ConfigureProviders.createDependencyTree();
  runApp(
    //MultiProvider(
    //providers: configureProviders.providers,
    const App(),
    // ),
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
      home: const Home(),
    );
  }
}
