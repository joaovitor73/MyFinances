import 'package:flutter/material.dart';
import 'package:my_finances/services/categoria_service.dart';
import 'package:my_finances/ui/pages/base_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_finances/services/limite_service.dart';

class AddLimitCategoria extends StatefulWidget {
  const AddLimitCategoria({super.key});

  @override
  State<AddLimitCategoria> createState() => _AddLimitCategoriaState();
}

class _AddLimitCategoriaState extends State<AddLimitCategoria> {
  final TextEditingController _limiteController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  Future<void> _addLimitCategoria() async {
    final limiteService = Provider.of<LimiteService>(context, listen: false);

    try {
      String id = await limiteService.idCategoriaLimiteSeExiste(
          categoria: _categoriaController.text);
      if (id != '0') {
        limiteService.sumLimite(
            id: id, valor: double.parse(_limiteController.text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Limite atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _limiteController.clear();
        _categoriaController.clear();
        setState(() {});
        return;
      }

      await limiteService.addLimite(
        limite: double.parse(_limiteController.text),
        categoria: _categoriaController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limite adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      _limiteController.clear();
      _categoriaController.clear();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao adicionar limite!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriaProvider = Provider.of<CategoriaService>(context);
    final limiteProvider = Provider.of<LimiteService>(context);

    return BaseScreen(
      currentIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Adicionar Limite',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue[900],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Limite de Gasto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _limiteController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Limite',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon:
                        const Icon(Icons.attach_money, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Categoria',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FutureBuilder(
                  future: categoriaProvider.obterCategoriasGastos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('Erro ao carregar categorias.');
                    }

                    final categorias = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      items: categorias
                          .map((categoria) => DropdownMenuItem(
                                value: categoria,
                                child: Text(categoria),
                              ))
                          .toList(),
                      onChanged: (value) {
                        _categoriaController.text = value!;
                      },
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon:
                            const Icon(Icons.category, color: Colors.blue),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addLimitCategoria,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Adicionar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Limites Adicionados',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FutureBuilder(
                  future: limiteProvider.getLimites(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('Erro ao carregar limites.');
                    }

                    final limites = snapshot.data;
                    if (limites!.isEmpty) {
                      return const Text('Nenhum limite cadastrado.');
                    }

                    return Column(
                      children: limites
                          .map<Widget>((limite) => Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.monetization_on,
                                    color: Colors.green,
                                  ),
                                  title: Text(limite['categoria']),
                                  subtitle: Text(
                                    'R\$ ${limite['limite'].toStringAsFixed(2)}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      limiteProvider.deleteLimite(
                                          id: limite['id']);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Limite deletado com sucesso!'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
