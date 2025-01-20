import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
final CollectionReference _mainCollection =
    _firebaseFirestore.collection('despesas');

class DespesasStoreService {
  static String? userUid = "q4YgLe7PXPhomeb4owObyCOBcvq2";

  Future<void> addDespesas(
      {String? dataPagamento,
      required String descricao,
      required double valor,
      required String data}) async {
    try {
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('despesas').doc();

      Map<String, dynamic> dados = <String, dynamic>{
        "dataPagamento": dataPagamento,
        "descricao": descricao,
        "valor": valor,
        "data": data,
      };

      await documentReferencer
          .set(dados)
          .whenComplete(() => print("Despesa adicionada ao banco de dados"))
          .catchError((e) => print(e));

      print('Despesa adicionada com sucesso!');
    } catch (e) {
      print('Erro ao adicionar despesa: $e');
    }
  }

  Future<void> deleteDespesas({required String id}) async {
    try {
      await _firebaseFirestore.collection('despesas').doc(id).delete();
      print('Despesa removida com sucesso!');
    } catch (e) {
      print('Erro ao remover despesa: $e');
    }
  }

  Future<void> updateDespesas(
      {String? dataPagamento,
      required String descricao,
      required double valor,
      required String data,
      required String id}) async {
    try {
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('despesas').doc(id);

      Map<String, dynamic> dados = <String, dynamic>{
        "dataPagamento": dataPagamento,
        "descricao": descricao,
        "valor": valor,
        "data": data,
      };

      await documentReferencer
          .update(dados)
          .whenComplete(() => print("Despesa atualizada no banco de dados"))
          .catchError((e) => print(e));

      print('Despesa atualizada com sucesso!');
    } catch (e) {
      print('Erro ao atualizar despesa: $e');
    }
  }

  Stream getDespesas() {
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('despesas');
    return documentReferencer.snapshots();
  }

  Stream<double> getTotalDespesas() {
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('despesas');

    return documentReferencer.snapshots().map((snapshot) {
      double total = 0.0;

      for (var doc in snapshot.docs) {
        if (doc['data'] == null) {
          continue;
        }
        total += doc['valor'] ?? 0.0;
      }
      return total;
    });
  }

  Stream<double> getTotalDespesasMes() {
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('despesas');
    return documentReferencer.snapshots().map((snapshot) {
      double total = 0.0;

      for (var doc in snapshot.docs) {
        if (doc['data'] == null) {
          continue;
        }
        DateTime data = DateTime.parse(doc['data']);
        if (data.month == DateTime.now().month) {
          total += doc['valor'] ?? 0.0;
        }
      }
      return total;
    });
  }
}
