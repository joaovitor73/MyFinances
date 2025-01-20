import 'package:my_finances/services/despesas_store_service.dart';

class ReceitaService {
  final DespesasStoreService despesas;

  ReceitaService({required this.despesas});

  Stream getTotalReceita() {
    return despesas.getTotalDespesas();
  }
}
