import 'package:cloud_firestore/cloud_firestore.dart';

class DespesasStoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> addDespesas(String descricao, double valor, String data) async {
    try {
      await _firebaseFirestore.collection('despesas').add({
        'descricao': descricao,
        'valor': valor,
        'data': data,
      });
      print('Despesa adicionada com sucesso!');
    } catch (e) {
      print('Erro ao adicionar despesa: $e');
    }
  }

  Future<void> deleteDespesas(String id) async {
    try {
      await _firebaseFirestore.collection('despesas').doc(id).delete();
      print('Despesa deletada com sucesso!');
    } catch (e) {
      print('Erro ao deletar despesa: $e');
    }
  }

  Future<void> updateDespesas(
      String id, String descricao, double valor, String data) async {
    try {
      await _firebaseFirestore.collection('despesas').doc(id).update({
        'descricao': descricao,
        'valor': valor,
        'data': data,
      });
      print('Despesa atualizada com sucesso!');
    } catch (e) {
      print('Erro ao atualizar despesa: $e');
    }
  }

  Stream<QuerySnapshot> getDespesas() {
    return _firebaseFirestore.collection('despesas').snapshots();
  }

  Stream<double> getTotalDespesas() {
    return _firebaseFirestore
        .collection('despesas')
        .snapshots()
        .map((snapshot) {
      double total = 0.0;

      for (var doc in snapshot.docs) {
        total += doc['valor'] ?? 0.0;
      }
      return total;
    });
  }

  Stream<double> getTotalDespesasMes(String mes) {
    return _firebaseFirestore
        .collection('despesas')
        .snapshots()
        .map((snapshot) {
      double total = 0.0;

      for (var doc in snapshot.docs) {
        if (doc['data'].toString().substring(5, 7) == mes) {
          total += doc['valor'] ?? 0.0;
        }
      }
      return total;
    });
  }

  Stream<double> getTotalDespesasAno(String ano) {
    return _firebaseFirestore
        .collection('despesas')
        .snapshots()
        .map((snapshot) {
      double total = 0.0;

      for (var doc in snapshot.docs) {
        if (doc['data'].toString().substring(0, 4) == ano) {
          total += doc['valor'] ?? 0.0;
        }
      }
      return total;
    });
  }
}
