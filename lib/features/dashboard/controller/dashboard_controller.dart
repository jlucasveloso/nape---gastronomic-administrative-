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

  double get cmvTotal => despesas
      .where((d) => d.tipo == 'cmv')
      .fold(0.0, (soma, d) => soma + d.valor);

  double get cmoTotal => despesas
      .where((d) => d.tipo == 'cmo')
      .fold(0.0, (soma, d) => soma + d.valor);

  double get despesasGeraisTotal => despesas
      .where((d) => d.tipo == 'geral')
      .fold(0.0, (soma, d) => soma + d.valor);

  double get lucroBruto => faturamentoTotal - cmvTotal;

  double get lucroLiquido => faturamentoTotal - custosTotal;

  double get lucro => lucroLiquido;

  double get margemLucroPercent =>
      faturamentoTotal == 0 ? 0 : (lucroLiquido / faturamentoTotal) * 100;

  double get cmoPercent =>
      faturamentoTotal == 0 ? 0 : (cmoTotal / faturamentoTotal) * 100;

  double get cmvPercent =>
      faturamentoTotal == 0 ? 0 : (cmvTotal / faturamentoTotal) * 100;

  bool get cmoDentroDoIdeal => cmoPercent <= 16;

  Map<String, double> get faturamentoPorCategoria {
    final Map<String, double> resultado = {};

    for (final v in vendas) {
      resultado[v.categoriaSnapshot] =
          (resultado[v.categoriaSnapshot] ?? 0) + v.valorTotal;
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

  Map<String, double> get dre {
    return {
      'Faturamento': faturamentoTotal,
      'CMV': cmvTotal,
      'Lucro bruto': lucroBruto,
      'CMO': cmoTotal,
      'Despesas gerais': despesasGeraisTotal,
      'Lucro líquido': lucroLiquido,
    };
  }

  List<Venda> vendasNoPeriodo(DateTime inicio, DateTime fim) {
    return vendas
        .where((v) => !v.data.isBefore(inicio) && !v.data.isAfter(fim))
        .toList();
  }

  List<Despesa> despesasNoPeriodo(DateTime inicio, DateTime fim) {
    return despesas
        .where((d) => !d.data.isBefore(inicio) && !d.data.isAfter(fim))
        .toList();
  }
}