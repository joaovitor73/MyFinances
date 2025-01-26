import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Para salvar o arquivo
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Para exibir o PDF
import 'package:open_file/open_file.dart'; // Para abrir o PDF
import 'categoria_service.dart';
import 'receita_service.dart';

class PdfService {
  final CategoriaService categoriaService;
  final ReceitaService receitaService;

  PdfService({required this.categoriaService, required this.receitaService});

  Future<void> gerarRelatorio(BuildContext context) async {
    final pdf = pw.Document();

    // Obter dados de receitas e categorias
    List<Map<String, dynamic>> receitas = await _obterReceitas();
    Map<String, double> totalDespesasPorCategoria =
        await categoriaService.getTotalDespesasCategoria();

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
            // Total de Despesas e Receitas
            _detalhesTotais(receitas, totalDespesasPorCategoria),
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
      receitas.add(doc.data());
    }

    return receitas;
  }

  pw.Widget _detalhesTotais(List<Map<String, dynamic>> receitas,
      Map<String, double> totalDespesasPorCategoria) {
    double totalReceitas = receitas.fold(0, (sum, item) => sum + item['valor']);
    double totalDespesas =
        totalDespesasPorCategoria.values.fold(0, (sum, item) => sum + item);

    return pw.Column(
      children: [
        pw.Text(
            'Total de Receitas: ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(totalReceitas)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            'Total de Despesas: ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(totalDespesas)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(
            'Saldo: ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(totalReceitas - totalDespesas)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      ],
    );
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
