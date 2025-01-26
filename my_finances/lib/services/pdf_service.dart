import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_finances/services/despesas_store_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'categoria_service.dart';
import 'receita_service.dart';

class PdfService {
  final CategoriaService categoriaService;
  final ReceitaService receitaService;
  final DespesasStoreService despesasSerc = DespesasStoreService();

  PdfService({required this.categoriaService, required this.receitaService});

  Future<void> gerarRelatorio(BuildContext context) async {
    final pdf = pw.Document();

    List<Map<String, dynamic>> receitas = await _obterReceitas();
    List<Map<String, dynamic>> despesas = await _obterDespesas();
    Map<String, double> totalDespesasPorCategoria =
        await categoriaService.getTotalDespesasCategoria();
    Map<String, double> totalReceitasPorCategoria =
        await categoriaService.getTotalReceitasCategoria();

    // Criar cabeçalho do PDF
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Relatório Financeiro',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),

            // Tabela de Receitas
            pw.Text('Receitas',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headers: ['Descrição', 'Valor', 'Data', 'Categoria'],
              data: receitas.map((receita) {
                return [
                  receita['descricao'],
                  NumberFormat.simpleCurrency(locale: 'pt_BR')
                      .format(receita['valor']),
                  receita['data'],
                  receita['categoria']
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Despesas',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headers: ['Descrição', 'Valor', 'Data', 'Categoria'],
              data: despesas.map((receita) {
                return [
                  receita['descricao'],
                  NumberFormat.simpleCurrency(locale: 'pt_BR')
                      .format(receita['valor']),
                  receita['data'],
                  receita['categoria']
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),

            // Tabela de Despesas por Categoria
            pw.Text('Despesas por Categoria',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headers: ['Categoria', 'Total Despesa'],
              data: totalDespesasPorCategoria.entries.map((entry) {
                return [
                  entry.key,
                  NumberFormat.simpleCurrency(locale: 'pt_BR')
                      .format(entry.value),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),

            // Tabela de Receitas por Categoria
            pw.Text('Receitas por Categoria',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headers: ['Categoria', 'Total Receita'],
              data: totalReceitasPorCategoria.entries.map((entry) {
                return [
                  entry.key,
                  NumberFormat.simpleCurrency(locale: 'pt_BR')
                      .format(entry.value),
                ];
              }).toList(),
            ),
          ],
        );
      },
    ));

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Estatísticas Financeiras',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            _detalhesEstatisticos(receitas, totalDespesasPorCategoria),
          ],
        );
      },
    ));

    // Salvar PDF no dispositivo
    final filePath = await _obterCaminhoArquivo();
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Exibir o PDF gerado
    _exibirPdf(file.path, context);
  }

  Future<List<Map<String, dynamic>>> _obterReceitas() async {
    List<Map<String, dynamic>> receitas = [];
    final receitasSnapshot = await receitaService.getReceitas().first;

    for (var doc in receitasSnapshot.docs) {
      receitas.add(doc.data() as Map<String, dynamic>);
    }

    return receitas;
  }

  Future<List<Map<String, dynamic>>> _obterDespesas() async {
    List<Map<String, dynamic>> despesas = [];
    final despesasSnapshot = await despesasSerc.getDespesas().first;

    for (var doc in despesasSnapshot.docs) {
      despesas.add(doc.data() as Map<String, dynamic>);
    }

    return despesas;
  }

  pw.Widget _detalhesEstatisticos(List<Map<String, dynamic>> receitas,
      Map<String, double> totalDespesasPorCategoria) {
    double totalReceitas = receitas.fold(0, (sum, item) => sum + item['valor']);
    double totalDespesas =
        totalDespesasPorCategoria.values.fold(0, (sum, item) => sum + item);
    double saldo = totalReceitas - totalDespesas;
    double percentualDespesas = (totalDespesas / totalReceitas) * 100;

    return pw.Column(
      children: [
        pw.Text(
            'Total de Receitas: ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(totalReceitas)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            'Total de Despesas: ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(totalDespesas)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            'Saldo: ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(saldo)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            'Percentual de Despesas: ${percentualDespesas.toStringAsFixed(2)}%',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),

        // Estatísticas adicionais
        pw.Text(
            'Categoria com Maior Despesa: ${_categoriaMaiorDespesa(totalDespesasPorCategoria)}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            'Categoria com Menor Despesa: ${_categoriaMenorDespesa(totalDespesasPorCategoria)}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),

        // Categoria com Maior Receita
        pw.Text(
            'Categoria com Maior Receita: ${_categoriaMaiorReceita(totalDespesasPorCategoria)}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            'Categoria com Menor Receita: ${_categoriaMenorReceita(totalDespesasPorCategoria)}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  String _categoriaMaiorDespesa(Map<String, double> totalDespesasPorCategoria) {
    if (totalDespesasPorCategoria.isEmpty) {
      return 'Nenhuma categoria encontrada';
    }

    var categoriaMaior = totalDespesasPorCategoria.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return categoriaMaior.key;
  }

  String _categoriaMenorDespesa(Map<String, double> totalDespesasPorCategoria) {
    if (totalDespesasPorCategoria.isEmpty) {
      return 'Nenhuma categoria encontrada';
    }

    var categoriaMenor = totalDespesasPorCategoria.entries
        .reduce((a, b) => a.value < b.value ? a : b);

    return categoriaMenor.key;
  }

  String _categoriaMaiorReceita(Map<String, double> totalReceitasPorCategoria) {
    if (totalReceitasPorCategoria.isEmpty) {
      return 'Nenhuma categoria encontrada';
    }

    var categoriaMaior = totalReceitasPorCategoria.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return categoriaMaior.key;
  }

  String _categoriaMenorReceita(Map<String, double> totalReceitasPorCategoria) {
    if (totalReceitasPorCategoria.isEmpty) {
      return 'Nenhuma categoria encontrada';
    }

    var categoriaMenor = totalReceitasPorCategoria.entries
        .reduce((a, b) => a.value < b.value ? a : b);

    return categoriaMenor.key;
  }

  Future<String> _obterCaminhoArquivo() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/relatorio_financeiro.pdf'; // Caminho do arquivo
    return filePath;
  }

  void _exibirPdf(String filePath, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(filePath: filePath),
      ),
    );
  }

  // Função para abrir o PDF gerado
  void abrirPdf(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      print("Erro ao abrir o arquivo PDF: ${result.message}");
    }
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String filePath;

  PdfViewerScreen({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Visualizar Relatório PDF',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Função para baixar o arquivo (abrir no visualizador de arquivos)
                OpenFile.open(filePath);
              },
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text(
                'Baixar PDF',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Cor de fundo
                minimumSize: const Size(double.infinity, 50), // Largura total
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 8.0,
                shadowColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PDFView(
                  filePath: filePath,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
