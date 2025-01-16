import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:my_finances/services/despesas_store_service.dart';
import 'package:my_finances/ui/pages/despesas_screen.dart';

import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final despesasStoreService = Provider.of<DespesasStoreService>(context);

    return MaterialApp(
      title: 'Minha Aplicação',
      home: Scaffold(
        appBar: AppBar(title: const Text('Navegação BottomBar')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DespesasScreen()),
              );
            },
            child: const Text('Ir para a tela de despesas'),
          ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: const IconThemeData(size: 22.0),
          visible: true,
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.add),
              backgroundColor: Colors.red,
              label: 'Adicionar despesa',
              labelStyle: const TextStyle(fontSize: 18.0),
              onTap: () {
                Navigator.pushNamed(context, '/list_despesas');
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.remove),
              backgroundColor: Colors.blue,
              label: 'Remover despesa',
              labelStyle: const TextStyle(fontSize: 18.0),
              onTap: () {
                //  despesasStoreService.removeDespesa();
              },
            ),
          ],
        ),
      ),
    );
  }
}
