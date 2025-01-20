import 'package:my_finances/services/despesas_store_service.dart';
import 'package:my_finances/services/receita_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  static Future<ConfigureProviders> createDependencyTree() async {
    DespesasStoreService despesasStoreService = DespesasStoreService();
    ReceitaService receitaService =
        ReceitaService(despesas: despesasStoreService);
    return ConfigureProviders(providers: [
      Provider<DespesasStoreService>.value(value: despesasStoreService),
      Provider<ReceitaService>.value(value: receitaService),
    ]);
  }
}
