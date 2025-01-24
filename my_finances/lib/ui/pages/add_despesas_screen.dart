import 'package:flutter/material.dart';
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

  Future<void> _addDespesas() async {
    if (_formKey.currentState!.validate()) {
      final despesasProvider =
          Provider.of<DespesasStoreService>(context, listen: false);
      await despesasProvider.addDespesas(
        dataPagamento: _dataPagamentoController.text,
        descricao: _descricaoController.text,
        valor: double.parse(_valorController.text),
        data: _dataController.text,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Despesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _dataPagamentoController,
                decoration: const InputDecoration(
                  labelText: 'Data de Pagamento (opcional)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                decoration: const InputDecoration(
                  labelText: 'Data da Despesa',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data da despesa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addDespesas,
                child: const Text('Salvar Despesa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
