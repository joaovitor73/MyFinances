import 'package:flutter/material.dart';
import 'package:my_finances/services/despesas_store_service.dart';
import 'package:my_finances/services/receita_service.dart';
import 'package:my_finances/ui/pages/base_screen.dart';
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
    return BaseScreen(
      currentIndex: 0,
      child: Scaffold(
        appBar: AppBar(title: const Text('MyFinances')),
        body: Center(
            child: Column(
          children: [
            StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return SizedBox(
                    height: 70,
                    child: CardDataFinances(
                        title: 'Total de Despesas: R\$ ', snapshot: snapshot),
                  );
                }),
            Row(
              children: [
                StreamBuilder(
                    stream: receitaProvider.getTotalReceita(),
                    builder: (context, snapshot) {
                      return Expanded(
                        child: CardDataFinances(
                            title: 'Total de Despesas: R\$ ',
                            snapshot: snapshot),
                      );
                    }),
                StreamBuilder<Object>(
                    stream: null,
                    builder: (context, snapshot) {
                      return Expanded(
                        child: CardDataFinances(
                            title: 'Total de Despesas: R\$ ',
                            snapshot: snapshot),
                      );
                    }),
              ],
            ),
            SizedBox(
              height: 300,
              child: FutureBuilder(
                  future: despesasProvider.getTotalDespesasMesUltimos3meses(),
                  builder: (context, snapshot) {
                    return ExpenseIncomeLineChart(
                      expenses: snapshot.data ?? [10, 20, 30],
                      incomes: [
                        150,
                        250,
                        100,
                      ],
                    );
                  }),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/list_despesas');
              },
              child: const Text('Listar despesas'),
            )
          ],
        )),
        floatingActionButton: MySpeedDial(despesasProvider: despesasProvider),
      ),
    );
  }
}
