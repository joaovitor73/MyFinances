import 'package:flutter/material.dart';
import 'package:my_finances/services/categoria_service.dart';
import 'package:my_finances/services/despesas_store_service.dart';
import 'package:provider/provider.dart';

class AddDespesasScreen extends StatefulWidget {
  const AddDespesasScreen({super.key});

  @override
  State<AddDespesasScreen> createState() => _AddDespesasScreenState();
}

class _AddDespesasScreenState extends State<AddDespesasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dataPagamentoController =
      TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  Future<void> _addDespesas() async {
    if (_formKey.currentState!.validate()) {
      final despesasProvider =
          Provider.of<DespesasStoreService>(context, listen: false);
      await despesasProvider.addDespesas(
        dataPagamento: _dataPagamentoController.text,
        descricao: _descricaoController.text,
        valor: double.parse(_valorController.text),
        data: _dataController.text,
        categoria: _categoriaController.text,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _dataPagamentoController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriaProvider = Provider.of<CategoriaService>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Adicionar Despesa',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red[900],
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _dataPagamentoController,
                  decoration:
                      const InputDecoration(labelText: 'Data Pagamento'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Data de pagamento é obrigatória';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Descrição é obrigatória';
                    }
                    return null;
                  },
                ),
                FutureBuilder(
                  future: categoriaProvider.obterCategoriasGastos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return DropdownButtonFormField(
                      items: snapshot.data!
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (value) {
                        _categoriaController.text = value.toString();
                      },
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      validator: (value) {
                        if (value == null) {
                          return 'Categoria é obrigatória';
                        }
                        return null;
                      },
                    );
                  },
                ),
                TextFormField(
                  controller: _valorController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Valor é obrigatório';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dataController,
                  readOnly: true, // O campo não será editável manualmente
                  decoration: const InputDecoration(
                    labelText: 'Data da Despesa',
                    suffixIcon:
                        Icon(Icons.calendar_today), // Ícone de calendário
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), // Data inicial no calendário
                      firstDate: DateTime(2000), // Data mínima
                      lastDate: DateTime(2100), // Data máxima
                    );

                    if (pickedDate != null) {
                      // Formata a data para exibição
                      String formattedDate =
                          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                      _dataController.text =
                          formattedDate; // Atualiza o texto no campo
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a data da despesa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addDespesas,
                  child: const Text('Adicionar Despesa'),
                ),
              ],
            ),
          ),
        ));
  }
}
