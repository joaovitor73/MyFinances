import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_finances/services/categoria_service.dart';
import 'package:my_finances/services/despesas_store_service.dart';
import 'package:my_finances/services/limite_service.dart';
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
  final StreamController<String?> _errorController =
      StreamController<String?>();
  String? _categoriaSelecionada;
  bool _podeCriarDespesa = false;

  Future<void> _addDespesas() async {
    if (_formKey.currentState!.validate() && _podeCriarDespesa) {
      final despesasProvider =
          Provider.of<DespesasStoreService>(context, listen: false);

      await despesasProvider.addDespesas(
        dataPagamento: _dataPagamentoController.text,
        descricao: _descricaoController.text,
        valor: double.parse(_valorController.text),
        data: _dataController.text,
        categoria: _categoriaController.text,
      );
      final limiteProvider = Provider.of<LimiteService>(context, listen: false);
      await limiteProvider.emitirNotificacaoLimite(
          _categoriaController.text, double.parse(_valorController.text));
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Despesa adicionada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Campos obrigatórios não preenchidos ou inválidos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _dataPagamentoController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    _categoriaController.dispose();
    _errorController.close();
    super.dispose();
  }

  void _validateField(String value) async {
    _podeCriarDespesa = false;
    if (value.isEmpty) {
      _errorController.add('Valor é obrigatório');
      return;
    }

    final valor = double.tryParse(value);
    if (valor == null) {
      _errorController.add('Digite um número válido');
      return;
    }

    final limiteProvider = Provider.of<LimiteService>(context, listen: false);

    final limiteRestante = await limiteProvider.limiteRestante(
      categoria: _categoriaController.text,
    );

    final String id = await limiteProvider.idCategoriaLimiteSeExiste(
      categoria: _categoriaController.text,
    );

    if (id == '0') {
      _errorController.add(null);
      _podeCriarDespesa = true;
      //_errorController.add('Categoria não possui limite cadastrado');
      return;
    }

    if (limiteRestante < valor) {
      _errorController
          .add('Despesa maior que o limite, restante: $limiteRestante');
      return;
    } else {
      _errorController.add(null);
      _podeCriarDespesa = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriaProvider = Provider.of<CategoriaService>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Adicionar Despesa',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        backgroundColor: Colors.red[900],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /* _buildInputField(
                controller: _dataPagamentoController,
                label: 'Data Pagamento',
                icon: Icons.date_range,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Data de pagamento é obrigatória';
                  }
                  return null;
                },
              ),*/
              const SizedBox(height: 16),
              _buildInputField(
                controller: _descricaoController,
                label: 'Descrição',
                icon: Icons.description,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Descrição é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder(
                future: categoriaProvider.obterCategoriasGastos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField(
                    value: _categoriaSelecionada,
                    items: snapshot.data!
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoriaSelecionada = value;
                        _categoriaController.text = value ?? '';
                      });
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
              const SizedBox(height: 16),
              if (_categoriaSelecionada != null &&
                  _categoriaSelecionada!.isNotEmpty)
                StreamBuilder<String?>(
                  stream: _errorController.stream,
                  builder: (context, snapshot) {
                    return _buildInputField(
                      controller: _valorController,
                      label: 'Valor',
                      icon: Icons.attach_money,
                      errorText: snapshot.data,
                      keyboardType: TextInputType.number,
                      onChanged: _validateField,
                    );
                  },
                ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _dataController,
                label: 'Data da Despesa',
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                    _dataController.text = formattedDate;
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
                style: ElevatedButton.styleFrom(
                  // // primary: Colors.red[900], // Define o color do botão
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Adicionar Despesa',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    bool readOnly = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black54), // Ícone no lado esquerdo
        errorText: errorText,
        //filled: true, // Cor de fundo mais suave
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
    );
  }
}
