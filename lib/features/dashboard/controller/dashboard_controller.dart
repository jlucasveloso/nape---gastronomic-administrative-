import '../model/venda.dart';
import '../model/despesa.dart';

class DashboardController {
  final List<Venda> vendas;
  final List<Despesa> despesas;

  const DashboardController({
    required this.vendas,
    required this.despesas,
  });

  double get faturamentoTotal =>
      vendas.fold(0.0, (soma, v) => soma + v.valorTotal);

  double get custosTotal =>
      despesas.fold(0.0, (soma, d) => soma + d.valor);

  double get lucro => faturamentoTotal - custosTotal;

  double get margemLucroPercent =>
      faturamentoTotal == 0 ? 0 : (lucro / faturamentoTotal) * 100;

  Map<String, double> get faturamentoPorCategoria {
  final Map<String, double> resultado = {};
  for (final v in vendas) {
    resultado[v.categoriaSnapshot] = (resultado[v.categoriaSnapshot] ?? 0) + v.valorTotal;
  }
  return resultado;
}

  Map<String, double> get custosPorCategoria {
    final Map<String, double> resultado = {};
    for (final d in despesas) {
      resultado[d.categoria] = (resultado[d.categoria] ?? 0) + d.valor;
    }
    return resultado;
  }

  List<Venda> vendasNoPeriodo(DateTime inicio, DateTime fim) =>
      vendas.where((v) => !v.data.isBefore(inicio) && !v.data.isAfter(fim)).toList();

  List<Despesa> despesasNoPeriodo(DateTime inicio, DateTime fim) =>
      despesas.where((d) => !d.data.isBefore(inicio) && !d.data.isAfter(fim)).toList();
}