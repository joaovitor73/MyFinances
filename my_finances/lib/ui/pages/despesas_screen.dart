import 'package:flutter/material.dart';
import 'package:my_finances/services/despesas_store_service.dart';
import 'package:my_finances/ui/pages/base_screen.dart';
import 'package:provider/provider.dart';

class DespesasScreen extends StatefulWidget {
  const DespesasScreen({super.key});

  @override
  State<DespesasScreen> createState() => _DespesasScreenState();
}

class _DespesasScreenState extends State<DespesasScreen> {
  @override
  Widget build(BuildContext context) {
    final despesasProvider = Provider.of<DespesasStoreService>(context);
    return BaseScreen(
      currentIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Finances'),
        ),
        body: StreamBuilder(
            stream: despesasProvider.getDespesas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final despesas = snapshot.data!.docs;

              return ListView.builder(
                itemCount: despesas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(despesas[index]['descricao']),
                    subtitle: Text(despesas[index]['valor'].toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        despesasProvider.deleteDespesas(id: despesas[index].id);
                        print('Despesa deletada com sucesso!');
                      },
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}
