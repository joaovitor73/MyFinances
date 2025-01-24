import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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
}
