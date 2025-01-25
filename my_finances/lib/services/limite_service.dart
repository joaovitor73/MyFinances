import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LimiteService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference _mainCollection =
      FirebaseFirestore.instance.collection('users');
  String userUid = FirebaseAuth.instance.currentUser!.uid;

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
