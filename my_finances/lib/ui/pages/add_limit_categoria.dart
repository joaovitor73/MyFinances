import 'package:flutter/material.dart';
import 'package:my_finances/services/categoria_service.dart';
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
      Navigator.of(context).pop(); // Fecha a tela após adicionar
    } catch (e) {
      // Mostra uma mensagem de erro caso algo dê errado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao adicionar limite!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final limiteService = Provider.of<LimiteService>(context);
    final categoria = Provider.of<CategoriaService>(context);
    return Scaffold(
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
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Categoria',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder(
                future: categoria.obterCategoriasGastos(),
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addLimitCategoria,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Adicionar',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
