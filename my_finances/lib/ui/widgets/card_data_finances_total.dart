import 'package:flutter/material.dart';

class CardDataFinancesTotal extends StatelessWidget {
  final double totalReceitas;
  final double totalDespesas;
  final double saldo;

  const CardDataFinancesTotal({
    super.key,
    required this.totalReceitas,
    required this.totalDespesas,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total de Receita: R\$ ${totalReceitas.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Total de Despesa: R\$ ${totalDespesas.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Saldo: R\$ ${saldo.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: saldo >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
