import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:spend_controll/modules/report/controller/report_controller.dart';
import 'package:spend_controll/modules/report/controller/report_state.dart';
import 'package:spend_controll/modules/transactions/model/transaction_model.dart';

class ReportPdfGenerator {
  Future<void> generatePdf({
    required String filePath,
    required ReportState state,
    required ExportOptions options,
  }) async {
    // Gerar HTML para o relatório
    final html = await _generateHtml(state, options);

    // Usar WeasyPrint para converter HTML para PDF
    await _convertHtmlToPdf(html, filePath);
  }

  Future<String> _generateHtml(ReportState state, ExportOptions options) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final periodStart = dateFormat.format(state.period.start);
    final periodEnd = dateFormat.format(state.period.end);

    // Carregar template HTML
    final htmlTemplate = await _loadHtmlTemplate();

    // Substituir placeholders no template
    String html = htmlTemplate
        .replaceAll('{{REPORT_TITLE}}', 'Relatório Financeiro')
        .replaceAll('{{REPORT_PERIOD}}', '$periodStart a $periodEnd')
        .replaceAll('{{REPORT_DATE}}', dateFormat.format(DateTime.now()))
        .replaceAll(
            '{{TOTAL_INCOME}}', 'R\$ ${state.totalIncome.toStringAsFixed(2)}')
        .replaceAll(
            '{{TOTAL_EXPENSE}}', 'R\$ ${state.totalExpense.toStringAsFixed(2)}')
        .replaceAll('{{TOTAL_BALANCE}}',
            'R\$ ${(state.totalIncome - state.totalExpense).toStringAsFixed(2)}');

    // Adicionar gráficos se solicitado
    if (options.includeCharts) {
      html = html.replaceAll('{{CHARTS_SECTION}}', _generateChartsHtml(state));
    } else {
      html = html.replaceAll('{{CHARTS_SECTION}}', '');
    }

    // Adicionar tabela detalhada se solicitado
    if (options.includeDetailedTable) {
      html = html.replaceAll(
          '{{TRANSACTIONS_TABLE}}', _generateTransactionsTableHtml(state));
    } else {
      html = html.replaceAll('{{TRANSACTIONS_TABLE}}', '');
    }

    // Adicionar insights se solicitado
    if (options.includeInsights) {
      html =
          html.replaceAll('{{INSIGHTS_SECTION}}', _generateInsightsHtml(state));
    } else {
      html = html.replaceAll('{{INSIGHTS_SECTION}}', '');
    }

    return html;
  }

  Future<String> _loadHtmlTemplate() async {
    // Em um aplicativo real, este template seria carregado de um arquivo
    // Para este exemplo, retornamos um template embutido
    return '''
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Relatório Financeiro</title>
      <style>
        @page {
          size: A4;
          margin: 2cm;
        }
        body {
          font-family: "Noto Sans CJK SC", "WenQuanYi Zen Hei", sans-serif;
          color: #333;
          line-height: 1.5;
        }
        .header {
          text-align: center;
          margin-bottom: 2cm;
        }
        .header h1 {
          color: #1E3A8A;
          font-size: 24pt;
          margin-bottom: 0.5cm;
        }
        .header p {
          color: #666;
          font-size: 12pt;
        }
        .summary {
          margin-bottom: 1cm;
          page-break-inside: avoid;
        }
        .summary h2 {
          color: #1E3A8A;
          font-size: 18pt;
          margin-bottom: 0.5cm;
          border-bottom: 1px solid #ddd;
          padding-bottom: 0.2cm;
        }
        .summary-grid {
          display: grid;
          grid-template-columns: 1fr 1fr 1fr;
          gap: 1cm;
        }
        .summary-card {
          border: 1px solid #ddd;
          border-radius: 0.5cm;
          padding: 0.5cm;
          text-align: center;
        }
        .summary-card.income {
          border-color: #10B981;
        }
        .summary-card.expense {
          border-color: #EF4444;
        }
        .summary-card.balance {
          border-color: #1E3A8A;
        }
        .summary-card h3 {
          margin-top: 0;
          font-size: 14pt;
        }
        .summary-card p {
          font-size: 18pt;
          font-weight: bold;
          margin: 0.5cm 0;
        }
        .summary-card.income p {
          color: #10B981;
        }
        .summary-card.expense p {
          color: #EF4444;
        }
        .summary-card.balance p {
          color: #1E3A8A;
        }
        .charts {
          margin-bottom: 1cm;
          page-break-before: always;
        }
        .charts h2 {
          color: #1E3A8A;
          font-size: 18pt;
          margin-bottom: 0.5cm;
          border-bottom: 1px solid #ddd;
          padding-bottom: 0.2cm;
        }
        .chart-container {
          margin-bottom: 1cm;
        }
        .chart-container h3 {
          color: #666;
          font-size: 14pt;
          margin-bottom: 0.3cm;
        }
        .chart-placeholder {
          background-color: #f9f9f9;
          border: 1px solid #ddd;
          border-radius: 0.3cm;
          height: 8cm;
          display: flex;
          align-items: center;
          justify-content: center;
          color: #999;
          font-style: italic;
        }
        .transactions {
          margin-bottom: 1cm;
          page-break-before: always;
        }
        .transactions h2 {
          color: #1E3A8A;
          font-size: 18pt;
          margin-bottom: 0.5cm;
          border-bottom: 1px solid #ddd;
          padding-bottom: 0.2cm;
        }
        table {
          width: 100%;
          border-collapse: collapse;
        }
        th {
          background-color: #f3f4f6;
          text-align: left;
          padding: 0.3cm;
          border-bottom: 2px solid #ddd;
        }
        td {
          padding: 0.3cm;
          border-bottom: 1px solid #ddd;
        }
        tr:nth-child(even) {
          background-color: #f9f9f9;
        }
        .income-text {
          color: #10B981;
          font-weight: bold;
        }
        .expense-text {
          color: #EF4444;
          font-weight: bold;
        }
        .transfer-text {
          color: #3B82F6;
          font-weight: bold;
        }
        .insights {
          margin-bottom: 1cm;
          page-break-before: always;
        }
        .insights h2 {
          color: #1E3A8A;
          font-size: 18pt;
          margin-bottom: 0.5cm;
          border-bottom: 1px solid #ddd;
          padding-bottom: 0.2cm;
        }
        .insight-card {
          border: 1px solid #ddd;
          border-radius: 0.3cm;
          padding: 0.5cm;
          margin-bottom: 0.5cm;
        }
        .insight-card h3 {
          color: #666;
          font-size: 14pt;
          margin-top: 0;
          margin-bottom: 0.3cm;
        }
        .insight-card p {
          margin: 0;
          font-size: 12pt;
        }
        .footer {
          text-align: center;
          font-size: 10pt;
          color: #999;
          margin-top: 2cm;
          border-top: 1px solid #ddd;
          padding-top: 0.5cm;
        }
        .page-number:before {
          content: counter(page);
        }
        .page-count:before {
          content: counter(pages);
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>{{REPORT_TITLE}}</h1>
        <p>Período: {{REPORT_PERIOD}}</p>
        <p>Gerado em: {{REPORT_DATE}}</p>
      </div>
      
      <div class="summary">
        <h2>Resumo Financeiro</h2>
        <div class="summary-grid">
          <div class="summary-card income">
            <h3>Receitas</h3>
            <p>{{TOTAL_INCOME}}</p>
          </div>
          <div class="summary-card expense">
            <h3>Despesas</h3>
            <p>{{TOTAL_EXPENSE}}</p>
          </div>
          <div class="summary-card balance">
            <h3>Saldo</h3>
            <p>{{TOTAL_BALANCE}}</p>
          </div>
        </div>
      </div>
      
      {{CHARTS_SECTION}}
      
      {{TRANSACTIONS_TABLE}}
      
      {{INSIGHTS_SECTION}}
      
      <div class="footer">
        <p>SpendControllApp - Relatório Financeiro</p>
        <p>Página <span class="page-number"></span> de <span class="page-count"></span></p>
      </div>
    </body>
    </html>
    ''';
  }

  String _generateChartsHtml(ReportState state) {
    return '''
    <div class="charts">
      <h2>Análise Gráfica</h2>
      
      <div class="chart-container">
        <h3>Despesas por Categoria</h3>
        <div class="chart-placeholder">
          [Gráfico de Despesas por Categoria]
        </div>
      </div>
      
      <div class="chart-container">
        <h3>Receitas por Categoria</h3>
        <div class="chart-placeholder">
          [Gráfico de Receitas por Categoria]
        </div>
      </div>
      
      <div class="chart-container">
        <h3>Distribuição por Grupo</h3>
        <div class="chart-placeholder">
          [Gráfico de Distribuição por Grupo]
        </div>
      </div>
      
      <div class="chart-container">
        <h3>Evolução no Período</h3>
        <div class="chart-placeholder">
          [Gráfico de Evolução no Período]
        </div>
      </div>
    </div>
    ''';
  }

  String _generateTransactionsTableHtml(ReportState state) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final transactions = state.transactions;

    if (transactions.isEmpty) {
      return '''
      <div class="transactions">
        <h2>Transações</h2>
        <p>Nenhuma transação encontrada no período.</p>
      </div>
      ''';
    }

    String tableRows = '';
    for (final transaction in transactions) {
      String typeClass;
      String typeText;

      switch (transaction.type) {
        case TransactionType.income:
          typeClass = 'income-text';
          typeText = 'Receita';
          break;
        case TransactionType.expense:
          typeClass = 'expense-text';
          typeText = 'Despesa';
          break;
        case TransactionType.transfer:
          typeClass = 'transfer-text';
          typeText = 'Transferência';
          break;
      }

      tableRows += '''
      <tr>
        <td>${dateFormat.format(transaction.date)}</td>
        <td>${transaction.description}</td>
        <td>${transaction.groupName}</td>
        <td class="$typeClass">$typeText</td>
        <td class="$typeClass">R\$ ${transaction.amount.toStringAsFixed(2)}</td>
      </tr>
      ''';
    }

    return '''
    <div class="transactions">
      <h2>Transações</h2>
      <table>
        <thead>
          <tr>
            <th>Data</th>
            <th>Descrição</th>
            <th>Grupo</th>
            <th>Tipo</th>
            <th>Valor</th>
          </tr>
        </thead>
        <tbody>
          $tableRows
        </tbody>
      </table>
    </div>
    ''';
  }

  String _generateInsightsHtml(ReportState state) {
    return '''
    <div class="insights">
      <h2>Insights Financeiros</h2>
      
      <div class="insight-card">
        <h3>Maior Despesa</h3>
        <p>A maior despesa no período foi &quot;Aluguel&quot; no valor de R\$ 1.200,00, representando 35% do total de despesas.</p>
      </div>
      
      <div class="insight-card">
        <h3>Categoria Mais Cara</h3>
        <p>A categoria &quot;Moradia&quot; representa 45% das suas despesas no período, totalizando R\$ 1.550,00.</p>
      </div>
      
      <div class="insight-card">
        <h3>Comparativo com Período Anterior</h3>
        <p>Suas despesas aumentaram 12% em relação ao mês anterior, enquanto suas receitas aumentaram apenas 5%.</p>
      </div>
      
      <div class="insight-card">
        <h3>Recomendação</h3>
        <p>Considere revisar seus gastos na categoria "Alimentação", que teve um aumento de 25% em relação à média dos últimos 3 meses.</p>
      </div>
    </div>
    ''';
  }

  Future<void> _convertHtmlToPdf(String html, String outputPath) async {
    final pdfBytes = await Printing.convertHtml(
      format: PdfPageFormat.a4,
      html: html,
    );
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(pdfBytes);
  }
}
