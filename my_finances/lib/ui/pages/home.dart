import 'package:flutter/material.dart';
import 'package:my_finances/services/despesas_store_service.dart';
import 'package:my_finances/services/receita_service.dart';
import 'package:my_finances/ui/pages/base_screen.dart';
import 'package:my_finances/ui/widgets/cardDataFinances.dart';
import 'package:my_finances/ui/widgets/ExpenseIncomeLineChart.dart';
import 'package:my_finances/ui/widgets/mySpeedDial.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentMonthIndex = DateTime.now().month - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final despesasProvider = Provider.of<DespesasStoreService>(context);
    despesasProvider.emitirDespesas();
  }

  @override
  Widget build(BuildContext context) {
    final despesasProvider = Provider.of<DespesasStoreService>(context);
    final receitaProvider = Provider.of<ReceitaService>(context);
    return BaseScreen(
      currentIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'MyFinances',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Cards com informações financeiras
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: receitaProvider.getTotalReceitas(),
                      builder: (context, snapshot) {
                        return CardDataFinances(
                          title: 'Total de Receita: R\$ ',
                          snapshot: snapshot,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StreamBuilder(
                      stream: despesasProvider.getTotalDespesas(),
                      builder: (context, snapshot) {
                        return CardDataFinances(
                          title: 'Total de Despesas: R\$ ',
                          snapshot: snapshot,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Gráfico de Despesas vs Receita
              SizedBox(
                height: 300,
                child: StreamBuilder(
                  stream: despesasProvider.getTotalDespesasMesUltimos3meses(),
                  builder: (context, snapshotDespesas) {
                    return StreamBuilder(
                      stream:
                          receitaProvider.getTotalReceitasMesUltimos3meses(),
                      builder: (context, snapshotReceitas) {
                        List<double> despesas =
                            snapshotDespesas.data ?? [0, 0, 0];
                        List<double> receitas =
                            snapshotReceitas.data ?? [0, 0, 0];

                        return ExpenseIncomeLineChart(
                          expenses: despesas,
                          incomes: receitas,
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Card com gastos por mês rolável horizontalmente
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: () {
                        setState(() {
                          _currentMonthIndex =
                              (_currentMonthIndex - 1 + 12) % 12;
                        });
                      },
                    ),
                    // Exibe o mês atual e os meses adjacentes
                    Expanded(
                      child: FutureBuilder(
                        future: Future.wait([
                          despesasProvider
                              .getTotalDespesasMesNumber(_currentMonthIndex),
                          receitaProvider
                              .getTotalReceitasMesNumber(_currentMonthIndex),
                        ]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Erro ao carregar os dados');
                          }

                          var despesas = snapshot.data?[0] ?? 0.0;
                          var receita = snapshot.data?[1] ?? 0.0;
                          String monthName = _getMonthName(_currentMonthIndex);
                          String year = DateTime.now().year.toString();

                          double total = receita - despesas;

                          return Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '$monthName / $year',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Despesas: R\$ ${despesas.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Receitas: R\$ ${receita.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Total: R\$ ${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        total < 0 ? Colors.red : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: () {
                        setState(() {
                          _currentMonthIndex = (_currentMonthIndex + 1) % 12;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: MySpeedDial(despesasProvider: despesasProvider),
      ),
    );
  }

  String _getMonthName(int index) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[index];
  }
}
