import 'package:flutter/material.dart';
import 'package:my_finances/services/despesas_store_service.dart';
import 'package:my_finances/services/receita_service.dart';
import 'package:my_finances/ui/widgets/ExpenseIncomeLineChart.dart';
import 'package:my_finances/ui/widgets/cardDataFinances.dart';
import 'package:my_finances/ui/widgets/mySpeedDial.dart';

import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final despesasProvider = Provider.of<DespesasStoreService>(context);
    final receitaProvider = Provider.of<ReceitaService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('MyFinances')),
      body: Center(
        child: StreamBuilder(
          stream: receitaProvider.getTotalReceita(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError) {
              return const Text('Algo deu errado');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return Center(
                child: Column(
              children: [
                SizedBox(
                  height: 70,
                  child: CardDataFinances(
                      title: 'Total de Despesas: R\$ ', snapshot: snapshot),
                ),
                Row(
                  children: [
                    CardDataFinances(
                        title: 'Total de Despesas: R\$ ', snapshot: snapshot),
                    CardDataFinances(
                        title: 'Total de Despesas: R\$ ', snapshot: snapshot),
                  ],
                ),
                const SizedBox(
                  height: 300,
                  child: ExpenseIncomeLineChart(
                    expenses: [100, 200, 150, 80, 120],
                    incomes: [150, 250, 100, 90, 130],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/list_despesas');
                  },
                  child: const Text('Listar despesas'),
                )
              ],
            ));
          },
        ),
      ),
      floatingActionButton: MySpeedDial(despesasProvider: despesasProvider),
    );
  }
}
