import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:my_finances/services/categoria_service.dart';
import 'package:my_finances/services/despesas_store_service.dart';
import 'package:my_finances/services/pdf_service.dart';
import 'package:provider/provider.dart';

class MySpeedDial extends StatefulWidget {
  const MySpeedDial({
    super.key,
    required this.despesasProvider,
  });

  final DespesasStoreService despesasProvider;

  @override
  State<MySpeedDial> createState() => _MySpeedDialState();
}

class _MySpeedDialState extends State<MySpeedDial> {
  void _gerarRelatorioPdf(BuildContext context) async {
    final gerarPdf =
        Provider.of<PdfService>(context, listen: false); // Obtém o PdfService
    await gerarPdf
        .gerarRelatorio(context); // Chama o método para gerar o relatório

    // Exibe um SnackBar para o usuário informando que o PDF foi gerado com sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Relatório PDF gerado com sucesso!')),
    );
  }

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
            Navigator.pushNamed(context, '/add_despesas');
            CategoriaService categoriaService = CategoriaService();
            categoriaService.adicionarCategorias();
            print('Adicionar despesa');
            //Navigator.pushNamed(context, '/list_despesas');
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
          label: 'Adicionar receitas',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            Navigator.pushNamed(context, '/add_receitas');
            print('Adicionar receita');
            //Navigator.pushNamed(context, '/list_despesas');
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.picture_as_pdf),
          backgroundColor: Colors.blue,
          label: 'Gerar Relatório PDF',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            _gerarRelatorioPdf(context);
            print('Gerar Relatório PDF');
          },
        ),
        // Adicione outros SpeedDialChild se necessário
      ],
    );
  }
}
