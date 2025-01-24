import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:my_finances/services/categoria_service.dart';
import 'package:my_finances/services/despesas_store_service.dart';

class MySpeedDial extends StatelessWidget {
  const MySpeedDial({
    super.key,
    required this.despesasProvider,
  });

  final DespesasStoreService despesasProvider;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22.0),
      visible: true,
      curve: Curves.bounceIn,
      elevation: 8.0,
      spacing: 8.0,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add),
          backgroundColor: Colors.red,
          label: 'Adicionar despesa',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            // despesasProvider.addDespesas(
            // descricao: 'Despesa 1', valor: 100.0, data: '01/01/2021');
            Navigator.pushNamed(context, '/add_despesas');
            CategoriaService categoriaService = CategoriaService();
            categoriaService.adicionarCategorias();
            print('Adicionar despesa');
            //Navigator.pushNamed(context, '/list_despesas');
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.remove),
          backgroundColor: Colors.blue,
          label: 'Remover despesa',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            Navigator.pushNamed(context, '/list_despesas');
          },
        ),
      ],
    );
  }
}
