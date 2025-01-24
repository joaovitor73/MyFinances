import 'package:flutter/material.dart';

class AddLimitCategoria extends StatefulWidget {
  const AddLimitCategoria({super.key});

  @override
  State<AddLimitCategoria> createState() => _AddLimitCategoriaState();
}

class _AddLimitCategoriaState extends State<AddLimitCategoria> {
  TextEditingController limite = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Limite',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: limite,
              decoration: const InputDecoration(
                labelText: 'Limite',
              ),
            ),
            FutureBuilder(
              future: null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(limite.text);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
