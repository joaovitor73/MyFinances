import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
final CollectionReference _mainCollection =
    FirebaseFirestore.instance.collection('users');
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class CategoriaService {
  Future<void> adicionarCategorias() async {
    try {
      List<String> categoriasGastos = [
        'Alimentação',
        'Transporte',
        'Moradia',
        'Saúde',
        'Lazer',
        'Energia/Água'
      ];

      List<String> categoriasReceitas = [
        'Salário',
        'Freelance/Trabalho Extra',
        'Investimentos',
        'Rendimento de Aluguéis',
        'Venda de Produtos',
        'Doações'
      ];

      await _firebaseFirestore.collection('categorias').doc('gastos').set({
        'categorias': categoriasGastos,
      });

      await _firebaseFirestore.collection('categorias').doc('receitas').set({
        'categorias': categoriasReceitas,
      });

      print("Categorias adicionadas com sucesso!");
    } catch (e) {
      print("Erro ao adicionar categorias: $e");
    }
  }

  Future<Map<String, List<String>>> obterCategorias() async {
    try {
      DocumentSnapshot gastosDoc =
          await _firebaseFirestore.collection('categorias').doc('gastos').get();
      DocumentSnapshot receitasDoc = await _firebaseFirestore
          .collection('categorias')
          .doc('receitas')
          .get();

      List<String> categoriasGastos =
          List<String>.from(gastosDoc['categorias']);
      List<String> categoriasReceitas =
          List<String>.from(receitasDoc['categorias']);

      return {
        'gastos': categoriasGastos,
        'receitas': categoriasReceitas,
      };
    } catch (e) {
      print("Erro ao obter categorias: $e");
      return {};
    }
  }

  Future<void> deletarCategorias() async {
    try {
      await _firebaseFirestore.collection('categorias').doc('gastos').delete();
      await _firebaseFirestore
          .collection('categorias')
          .doc('receitas')
          .delete();

      print("Categorias deletadas com sucesso!");
    } catch (e) {
      print("Erro ao deletar categorias: $e");
    }
  }

  Future<List<String>> obterCategoriasGastos() async {
    try {
      DocumentSnapshot gastosDoc =
          await _firebaseFirestore.collection('categorias').doc('gastos').get();

      List<String> categoriasGastos =
          List<String>.from(gastosDoc['categorias']);

      return categoriasGastos;
    } catch (e) {
      print("Erro ao obter categorias de gastos: $e");
      return [];
    }
  }

  Future<List<String>> obterCategoriasReceitas() async {
    try {
      DocumentSnapshot receitasDoc = await _firebaseFirestore
          .collection('categorias')
          .doc('receitas')
          .get();

      List<String> categoriasReceitas =
          List<String>.from(receitasDoc['categorias']);

      return categoriasReceitas;
    } catch (e) {
      print("Erro ao obter categorias de receitas: $e");
      return [];
    }
  }

  Future<Map<String, double>> getTotalDespesasCategoria() async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      QuerySnapshot querySnapshot =
          await _mainCollection.doc(userUid).collection('despesas').get();

      Map<String, double> totalDespesasPorCategoria = {};

      querySnapshot.docs.forEach((doc) {
        String categoria = doc['categoria'];
        double valor = doc['valor'];

        if (totalDespesasPorCategoria.containsKey(categoria)) {
          totalDespesasPorCategoria[categoria] =
              totalDespesasPorCategoria[categoria]! + valor;
        } else {
          totalDespesasPorCategoria[categoria] = valor;
        }
      });

      return totalDespesasPorCategoria;
    } catch (e, stackTrace) {
      print("Erro ao obter total de despesas por categoria: $e");
      print(stackTrace);
      return {};
    }
  }

  Future<Map<String, double>> getTotalReceitasCategoria() async {
    try {
      final String userUid = _firebaseAuth.currentUser!.uid;
      QuerySnapshot querySnapshot =
          await _mainCollection.doc(userUid).collection('receitas').get();

      Map<String, double> totalReceitasPorCategoria = {};

      querySnapshot.docs.forEach((doc) {
        String categoria = doc['categoria'];
        double valor = doc['valor'];

        if (totalReceitasPorCategoria.containsKey(categoria)) {
          totalReceitasPorCategoria[categoria] =
              totalReceitasPorCategoria[categoria]! + valor;
        } else {
          totalReceitasPorCategoria[categoria] = valor;
        }
      });

      return totalReceitasPorCategoria;
    } catch (e, stackTrace) {
      print("Erro ao obter total de receitas por categoria: $e");
      print(stackTrace);
      return {};
    }
  }
}
