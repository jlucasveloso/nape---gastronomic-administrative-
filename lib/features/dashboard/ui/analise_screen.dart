import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj_nape/app_state.dart';
import 'package:proj_nape/features/dashboard/controller/dashboard_controller.dart';
import 'package:intl/intl.dart';

enum TipoAnalise {
  faturamento,
  lucro,
  despesa,
}

class AnaliseScreen extends StatefulWidget {
  const AnaliseScreen({super.key});

  @override
  State<AnaliseScreen> createState() => _AnaliseScreenState();
}

class _AnaliseScreenState extends State<AnaliseScreen> {
  TipoAnalise _tipo = TipoAnalise.faturamento;

  final List<Color> _cores = const [
    Color(0xFF2D74C4),
    Color(0xFFC2463C),
    Color(0xFF3E8E41),
    Color(0xFFF4A261),
    Color(0xFF8E44AD),
    Color(0xFF00A896),
    Color(0xFF6C757D),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final controller = DashboardController(
      vendas: appState.vendas,
      despesas: appState.despesas,
    );

    final dados = _dados(controller);
    final entradas = dados.entries.toList();

    final fmt = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE9E4DF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFC2463C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const Text(
              'Análise',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    _opcao('Faturamento', TipoAnalise.faturamento),
                    const SizedBox(width: 8),
                    _opcao('Lucro', TipoAnalise.lucro),
                    const SizedBox(width: 8),
                    _opcao('Despesa', TipoAnalise.despesa),
                  ],
                ),
                const SizedBox(height: 20),
                if (dados.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: Text(
                        'Sem dados para analisar.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                else ...[
                  _card(
                    'Gráfico pizza',
                    Column(
                      children: [
                        SizedBox(
                          height: 240,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 48,
                              sections: entradas.asMap().entries.map((item) {
                                final index = item.key;
                                final entry = item.value;

                                return PieChartSectionData(
                                  value: entry.value,
                                  title: '',
                                  radius: 72,
                                  color: _cores[index % _cores.length],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _legenda(entradas, fmt),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    'Gráfico colunas',
                    Column(
                      children: [
                        SizedBox(
                          height: 260,
                          child: BarChart(
                            BarChartData(
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              barGroups: entradas.asMap().entries.map((item) {
                                final index = item.key;
                                final entry = item.value;

                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value,
                                      width: 24,
                                      color: _cores[index % _cores.length],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _legenda(entradas, fmt),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    'Resumo',
                    Column(
                      children: entradas.asMap().entries.map((item) {
                        final index = item.key;
                        final entry = item.value;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _cores[index % _cores.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                fmt.format(entry.value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcao(String texto, TipoAnalise tipo) {
    final selecionado = _tipo == tipo;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tipo = tipo;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selecionado ? const Color(0xFFC2463C) : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selecionado ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(String titulo, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _legenda(
    List<MapEntry<String, double>> entradas,
    NumberFormat fmt,
  ) {
    return Column(
      children: entradas.asMap().entries.map((item) {
        final index = item.key;
        final entry = item.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _cores[index % _cores.length],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Text(
                fmt.format(entry.value),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, double> _dados(DashboardController controller) {
    switch (_tipo) {
      case TipoAnalise.faturamento:
        return controller.faturamentoPorCategoria;

      case TipoAnalise.despesa:
        return controller.custosPorCategoria;

      case TipoAnalise.lucro:
        return {
          'Faturamento': controller.faturamentoTotal,
          'Custos': controller.custosTotal,
          'Lucro': controller.lucroLiquido < 0
              ? controller.lucroLiquido.abs()
              : controller.lucroLiquido,
        };
    }
  }
}