import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:my_finances/utils/calendar_utils.dart';

class DespesasStoreService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addDespesas({
    required String descricao,
    required double valor,
    required String data,
    String? dataPagamento,
    required String categoria,
  }) async {
    final String userUid = _firebaseAuth.currentUser!.uid;
    try {
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('despesas').doc();

      Map<String, dynamic> dados = <String, dynamic>{
        "descricao": descricao,
        "valor": valor,
        "data": data,
        "dataPagamento": dataPagamento,
        "categoria": categoria,
      };

      await documentReferencer
          .set(dados)
          .whenComplete(() => print("Despesa adicionada ao banco de dados"))
          .catchError((e) => print(e));

      print('Despesa adicionada com sucesso!');
      emitirDespesas();
    } catch (e) {
      print('Erro ao adicionar despesa: $e');
    }
  }

  Future<void> deleteDespesas({required String id}) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('despesas').doc(id);

      await documentReferencer
          .delete()
          .whenComplete(() => print("Despesa deletada do banco de dados"))
          .catchError((e) => print(e));

      print('Despesa deletada com sucesso!');
      emitirDespesas();
    } catch (e) {
      print('Erro ao deletar despesa: $e');
    }
  }

  Future<void> updateDespesas(
      {String? dataPagamento,
      required String descricao,
      required double valor,
      required String data,
      required String id,
      required String categoria}) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('despesas').doc(id);

      Map<String, dynamic> dados = <String, dynamic>{
        "dataPagamento": dataPagamento,
        "descricao": descricao,
        "valor": valor,
        "data": data,
        "categoria": categoria,
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
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('despesas');

    return documentReferencer.snapshots();
  }

  Future<double> getTotalDespesasMesNumber(int mes) {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('despesas');
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

  Stream<double> getTotalDespesas() {
    final String userUid = _firebaseAuth.currentUser!.uid;
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
    final String userUid = _firebaseAuth.currentUser!.uid;
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

  Stream<double> getTotalDespesasCategoriaMes(String categoria) {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('despesas');

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

  Stream<double> getTotalDespesasCategoria(String categoria) {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('despesas');

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

  final StreamController<List<double>> _despesasStreamController =
      StreamController<List<double>>.broadcast();

  Stream<List<double>> getTotalDespesasMesUltimos3meses() {
    return _despesasStreamController.stream;
  }

  Future<void> emitirDespesas() async {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('despesas');

    QuerySnapshot querySnapshot = await documentReferencer.get();

    List<double> totalDespesas = [];

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
      totalDespesas.add(total);
    }

    // Adiciona os totais na stream (pode emitir novos dados para o StreamBuilder)
    _despesasStreamController.add(totalDespesas.reversed.toList());
  }

  void dispose() {
    _despesasStreamController.close();
  }

/*
Stream<List<double>> getTotalDespesasMesUltimos3meses() async* {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('despesas');

    // Obtém os documentos de forma assíncrona
    QuerySnapshot querySnapshot = await documentReferencer.get();

    List<double> totalDespesas = [];

    // Para cada mês dos últimos 3 meses
    for (int i = 0; i < 3; i++) {
      double total = 0.0;
      for (var doc in querySnapshot.docs) {
        if (doc['data'] == null) {
          continue;
        }

        // Formatar a data
        DateFormat format = DateFormat("dd-MM-yyyy");
        DateTime data = format.parse(doc['data']);

        // Verifica se o mês do documento corresponde ao mês desejado
        if (data.month == CalendarUtils.getMesAnterior(i)) {
          total += doc['valor'] ?? 0.0;
        }
      }
      totalDespesas.add(total);
    }

    // Emite a lista de totais de despesas
    yield totalDespesas.reversed.toList();
  }
Stream<List<double>> getTotalDespesasMesUltimos3meses()  {
    final String userUid = _firebaseAuth.currentUser!.uid;
    CollectionReference documentReferencer =
        _mainCollection.doc(userUid).collection('despesas');

    QuerySnapshot querySnapshot =  documentReferencer.get();

    List<double> totalDespesas = [];

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
      totalDespesas.add(total);
    }
    return totalDespesas.reversed.toList();
  }
*/
}
