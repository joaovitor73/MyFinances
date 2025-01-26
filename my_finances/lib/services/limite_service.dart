import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_finances/services/notification_service.dart';

class LimiteService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');
  // String userUid = FirebaseAuth.instance.currentUser!.uid;

  final NotificationService _notificationService = NotificationService();

  Future<void> initNotifications() async {
    await _notificationService.init();
  }

  Future<void> addLimite({
    required double limite,
    required String categoria,
  }) async {
    final String userUid = _firebaseAuth.currentUser!.uid;
    try {
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('limites').doc();

      Map<String, dynamic> dados = <String, dynamic>{
        "limite": limite,
        "categoria": categoria,
      };

      await documentReferencer
          .set(dados)
          .whenComplete(() => print("Limite adicionado ao banco de dados"))
          .catchError((e) => print(e));

      print('Limite adicionado com sucesso!');
    } catch (e) {
      print('Erro ao adicionar limite: $e');
    }
  }

  Future<void> deleteLimite({required String id}) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('limites').doc(id);

      await documentReferencer
          .delete()
          .whenComplete(() => print("Limite deletado do banco de dados"))
          .catchError((e) => print(e));

      print('Limite deletado com sucesso!');
    } catch (e) {
      print('Erro ao deletar limite: $e');
    }
  }

  Future<void> updateLimite(
      {required String id, required double limite}) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('limites').doc(id);

      Map<String, dynamic> dados = <String, dynamic>{
        "limite": limite,
      };

      await documentReferencer
          .update(dados)
          .whenComplete(() => print("Limite atualizado no banco de dados"))
          .catchError((e) => print(e));

      print('Limite atualizado com sucesso!');
    } catch (e) {
      print('Erro ao atualizar limite: $e');
    }
  }

  Future<String> idCategoriaLimiteSeExiste({required String categoria}) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      QuerySnapshot querySnapshot = await _mainCollection
          .doc(userUid)
          .collection('limites')
          .where('categoria', isEqualTo: categoria)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0].id;
      } else {
        return '0';
      }
    } catch (e) {
      print('Erro ao obter id do limite: $e');
      return '0';
    }
  }

  Future<void> sumLimite({required id, required double valor}) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      DocumentReference documentReferencer =
          _mainCollection.doc(userUid).collection('limites').doc(id);

      Map<String, dynamic> dados = <String, dynamic>{
        "limite": FieldValue.increment(valor),
      };

      await documentReferencer
          .update(dados)
          .whenComplete(() => print("Limite somado no banco de dados"))
          .catchError((e) => print(e));

      print('Limite somado com sucesso!');
    } catch (e) {
      print('Erro ao somar limite: $e');
    }
  }

  Future<bool> valorDespesaMenorQueLimite(
      {required double valor, required String categoria}) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      QuerySnapshot querySnapshot = await _mainCollection
          .doc(userUid)
          .collection('limites')
          .where('categoria', isEqualTo: categoria)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print(querySnapshot.docs);
        double limite = querySnapshot.docs[0]['limite'];
        return valor <= limite;
      } else {
        return true;
      }
    } catch (e) {
      print('Erro ao obter limite: $e');
      return false;
    }
  }

  Future<double> limiteRestante({required String categoria}) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      QuerySnapshot querySnapshot = await _mainCollection
          .doc(userUid)
          .collection('limites')
          .where('categoria', isEqualTo: categoria)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        double limite = querySnapshot.docs[0]['limite'];
        double totalDespesas = 0.0;
        QuerySnapshot querySnapshotDespesas = await _mainCollection
            .doc(userUid)
            .collection('despesas')
            .where('categoria', isEqualTo: categoria)
            .get();
        querySnapshotDespesas.docs.forEach((doc) {
          totalDespesas += doc['valor'];
        });

        return limite - totalDespesas;
      } else {
        return 0.0;
      }
    } catch (e) {
      print('Erro ao obter limite: $e');
      return 0.0;
    }
  }

  Future<void> emitirNotificacaoLimite(String categoria, double valor) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      QuerySnapshot querySnapshot = await _mainCollection
          .doc(userUid)
          .collection('limites')
          .where('categoria', isEqualTo: categoria)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        double limite = querySnapshot.docs[0]['limite'];
        double totalDespesas = 0.0;
        QuerySnapshot querySnapshotDespesas = await _mainCollection
            .doc(userUid)
            .collection('despesas')
            .where('categoria', isEqualTo: categoria)
            .get();
        querySnapshotDespesas.docs.forEach((doc) {
          totalDespesas += doc['valor'];
        });

        if (totalDespesas >= limite) {
          _notificationService.showNotification(
              title: 'Limite atingido!',
              body:
                  'O limite de $categoria foi atingido. Limite: R\$ $limite, Total de despesas: R\$ ${totalDespesas}');
        } else {
          emitirNotificacaoLimiteProximo(categoria, valor);
        }
      }
    } catch (e) {
      print('Erro ao emitir notificação de limite: $e');
    }
  }

  Future<void> emitirNotificacaoLimiteProximo(
      String categoria, double valor) async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      QuerySnapshot querySnapshot = await _mainCollection
          .doc(userUid)
          .collection('limites')
          .where('categoria', isEqualTo: categoria)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        double limite = querySnapshot.docs[0]['limite'];
        double totalDespesas = 0.0;
        QuerySnapshot querySnapshotDespesas = await _mainCollection
            .doc(userUid)
            .collection('despesas')
            .where('categoria', isEqualTo: categoria)
            .get();
        querySnapshotDespesas.docs.forEach((doc) {
          totalDespesas += doc['valor'];
        });

        if (totalDespesas + valor >= limite) {
          _notificationService.showNotification(
              title: 'Limite próximo!',
              body:
                  'O limite de $categoria está próximo de ser atingido. Limite: R\$ $limite, Total de despesas: R\$ ${totalDespesas}');
        }
      }
    } catch (e) {
      print('Erro ao emitir notificação de limite próximo: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLimites() async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      QuerySnapshot querySnapshot =
          await _mainCollection.doc(userUid).collection('limites').get();

      List<Map<String, dynamic>> limites = querySnapshot.docs
          .map((doc) => {
                "id": doc.id,
                "limite": doc['limite'],
                "categoria": doc['categoria'],
              })
          .toList();

      return limites;
    } catch (e) {
      print('Erro ao obter limites: $e');
      return [];
    }
  }

  Future<Map<String, double>> getLimitesCategoria() async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      QuerySnapshot querySnapshot =
          await _mainCollection.doc(userUid).collection('limites').get();

      Map<String, double> limites = {};

      querySnapshot.docs.forEach((doc) {
        limites[doc['categoria']] = doc['limite'];
      });

      return limites;
    } catch (e) {
      print('Erro ao obter limites: $e');
      return {};
    }
  }

  Future<List<String>> getCategoriasSemLimites() async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      QuerySnapshot querySnapshot =
          await _mainCollection.doc(userUid).collection('categorias').get();

      List<String> categorias = querySnapshot.docs
          .map((doc) => doc['categoria'])
          .toList()
          .cast<String>();

      List<String> categoriasComLimites =
          (await getLimitesCategoria()).keys.toList();

      List<String> categoriasSemLimites = categorias
          .where((categoria) => !categoriasComLimites.contains(categoria))
          .toList();

      return categoriasSemLimites;
    } catch (e) {
      print('Erro ao obter categorias sem limites: $e');
      return [];
    }
  }
}
