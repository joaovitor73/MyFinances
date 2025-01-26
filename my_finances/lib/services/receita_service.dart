import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:my_finances/utils/calendar_utils.dart';

class ReceitaService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addReceitas({
    required String descricao,
    required double valor,
    required String data,
    String? dataRecebimento,
    required String categoria,
  }) async {
    final String userUid = _firebaseAuth.currentUser!.uid;
    try {
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('receitas').doc();

      Map<String, dynamic> dados = <String, dynamic>{
        "descricao": descricao,
        "valor": valor,
        "data": data,
        "dataRecebimento": dataRecebimento,
        "categoria": categoria,
      };

      await documentReferencer
          .set(dados)
          .whenComplete(() => print("Receita adicionada ao banco de dados"))
          .catchError((e) => print(e));

      print('Receita adicionada com sucesso!');
      emitirReceitas();
    } catch (e) {
      print('Erro ao adicionar receita: $e');
    }
  }

  Future<void> deleteReceitas({required String id}) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('receitas').doc(id);

      await documentReferencer
          .delete()
          .whenComplete(() => print("Receita deletada do banco de dados"))
          .catchError((e) => print(e));

      print('Receita deletada com sucesso!');
      emitirReceitas();
    } catch (e) {
      print('Erro ao deletar receita: $e');
    }
  }

  Future<void> updateReceitas(
      {String? dataRecebimento,
      required String descricao,
      required double valor,
      required String data,
      required String id,
      required String categoria}) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('receitas').doc(id);

      Map<String, dynamic> dados = <String, dynamic>{
        "dataRecebimento": dataRecebimento,
        "descricao": descricao,
        "valor": valor,
        "data": data,
        "categoria": categoria,
      };

      await documentReferencer
          .update(dados)
          .whenComplete(() => print("Receita atualizada no banco de dados"))
          .catchError((e) => print(e));

      print('Receita atualizada com sucesso!');
    } catch (e) {
      print('Erro ao atualizar receita: $e');
    }
  }

  Stream getReceitas() {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('receitas');

    return documentReferencer.snapshots();
  }

  Future<double> getTotalReceitasMesNumber(int mes) {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('receitas');
    mes += 1;
    return documentReferencer.get().then((querySnapshot) {
      double total = 0.0;

      for (var doc in querySnapshot.docs) {
        if (doc['data'] == null) {
          continue;
        }
        DateFormat format = DateFormat("dd-MM-yyyy");

        DateTime data = format.parse(doc['data']);
        if (data.month == mes) {
          total += doc['valor'] ?? 0.0;
        }
      }
      return total;
    });
  }

  Stream<double> getTotalReceitas() {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('receitas');

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

  Stream<double> getTotalReceitasMes() {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('receitas');
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

  Stream<double> getTotalReceitasCategoriaMes(String categoria) {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('receitas');

    return documentReferencer.snapshots().map((snapshot) {
      double total = 0.0;

      for (var doc in snapshot.docs) {
        if (doc['data'] == null) {
          continue;
        }
        DateTime data = DateTime.parse(doc['data']);
        if (data.month == DateTime.now().month &&
            doc['categoria'] == categoria) {
          total += doc['valor'] ?? 0.0;
        }
      }
      return total;
    });
  }

  Stream<double> getTotalReceitasCategoria(String categoria) {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('receitas');

    return documentReferencer.snapshots().map((snapshot) {
      double total = 0.0;

      for (var doc in snapshot.docs) {
        if (doc['data'] == null) {
          continue;
        }
        if (doc['categoria'] == categoria) {
          total += doc['valor'] ?? 0.0;
        }
      }
      return total;
    });
  }

  final StreamController<List<double>> _receitasStreamController =
      StreamController<List<double>>.broadcast();

  Stream<List<double>> getTotalReceitasMesUltimos3meses() {
    return _receitasStreamController.stream;
  }

  Future<void> emitirReceitas() async {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('receitas');

    QuerySnapshot querySnapshot = await documentReferencer.get();

    List<double> totalReceitas = [];

    for (int i = 0; i < 3; i++) {
      double total = 0.0;
      for (var doc in querySnapshot.docs) {
        if (doc['data'] == null) {
          continue;
        }
        DateFormat format = DateFormat("dd-MM-yyyy");
        DateTime data = format.parse(doc['data']);
        if (data.month == CalendarUtils.getMesAnterior(i)) {
          total += doc['valor'] ?? 0.0;
        }
      }
      totalReceitas.add(total);
    }

    _receitasStreamController.add(totalReceitas.reversed.toList());
  }

  void dispose() {
    _receitasStreamController.close();
  }
}
