import 'package:flutter/material.dart';
import 'package:my_finances/services/categoria_service.dart';
import 'package:my_finances/services/receita_service.dart';
import 'package:provider/provider.dart';

class AddReceitasScreen extends StatefulWidget {
  const AddReceitasScreen({super.key});

  @override
  State<AddReceitasScreen> createState() => _AddReceitasScreenState();
}

class _AddReceitasScreenState extends State<AddReceitasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  String? _categoriaSelecionada;

  Future<void> _addReceitas() async {
    if (_formKey.currentState!.validate()) {
      final receitasProvider =
          Provider.of<ReceitaService>(context, listen: false);

      await receitasProvider.addReceitas(
        descricao: _descricaoController.text,
        valor: double.parse(_valorController.text),
        data: _dataController.text,
        categoria: _categoriaController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receita adicionada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos corretamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriaProvider = Provider.of<CategoriaService>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Adicionar Receita',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        backgroundColor: Colors.green[700],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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
              _buildInputField(
                controller: _valorController,
                label: 'Valor',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Valor é obrigatório';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Digite um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _dataController,
                label: 'Data da Receita',
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
                    return 'Por favor, insira a data da receita';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              FutureBuilder(
                future: categoriaProvider.obterCategoriasReceitas(),
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
              ElevatedButton(
                onPressed: _addReceitas,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Adicionar Receita',
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
    bool readOnly = false,
    TextInputType? keyboardType,
    Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
    );
  }
}
