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
          centerTitle: true,
          title: const Text(
            'Minhas Despesas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder(
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
                    final despesa = despesas[index];
                    final descricao = despesa['descricao'] ?? 'Sem descrição';
                    final valor = despesa['valor'] ?? 0.0;
                    final tipo = despesa['categoria'] ??
                        'Despesa'; // Supondo que tenha um campo para tipo (despesa ou receita)
                    final cor = Colors.red;

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(
                          tipo == 'Despesa'
                              ? Icons.remove_circle
                              : Icons.add_circle,
                          color: cor,
                          size: 32,
                        ),
                        title: Text(
                          descricao,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'R\$ ${valor.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: cor,
                            fontSize: 16,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            despesasProvider.deleteDespesas(id: despesa.id);
                            print('Despesa deletada com sucesso!');
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
        ),
      ),
    );
  }
}
