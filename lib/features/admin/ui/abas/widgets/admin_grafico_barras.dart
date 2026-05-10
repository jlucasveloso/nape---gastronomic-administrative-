import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminGraficoBarras extends StatelessWidget {
  final Map<DateTime, double> dadosFat;
  final Map<DateTime, double> dadosCus;
  final Map<DateTime, double> dadosLuc;
  final List<DateTime> dias;

  const AdminGraficoBarras({
    super.key,
    required this.dadosFat,
    required this.dadosCus,
    required this.dadosLuc,
    required this.dias,
  });

  @override
  Widget build(BuildContext context) {
    final fmtDia = DateFormat('dd/MM', 'pt_BR');

    final diasComDados = dias
        .where((d) => (dadosFat[d] ?? 0) > 0 || (dadosCus[d] ?? 0) > 0)
        .length;

    final barWidth = diasComDados <= 3
        ? 16.0
        : diasComDados <= 7
            ? 10.0
            : dias.length <= 7
                ? 8.0
                : 4.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legenda
          Row(
            children: [
              _Legenda(cor: const Color(0xFF2D74C4), label: 'Faturamento'),
              const SizedBox(width: 12),
              _Legenda(cor: const Color(0xFFC2463C), label: 'Custos'),
              const SizedBox(width: 12),
              _Legenda(cor: const Color(0xFF3E8E41), label: 'Lucro'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= dias.length) {
                          return const SizedBox.shrink();
                        }
                        final intervalo = dias.length <= 7
                            ? 1
                            : (dias.length / 5).ceil();
                        if (idx % intervalo != 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          fmtDia.format(dias[idx]),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black38,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: dias.asMap().entries.map((e) {
                  final idx = e.key;
                  final dia = e.value;
                  final fat = dadosFat[dia] ?? 0;
                  final cus = dadosCus[dia] ?? 0;
                  final luc = dadosLuc[dia] ?? 0;

                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: fat,
                        color: const Color(0xFF2D74C4),
                        width: barWidth,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      BarChartRodData(
                        toY: cus,
                        color: const Color(0xFFC2463C),
                        width: barWidth,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      BarChartRodData(
                        toY: luc < 0 ? 0 : luc,
                        color: const Color(0xFF3E8E41),
                        width: barWidth,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                    barsSpace: 2,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  final Color cor;
  final String label;

  const _Legenda({required this.cor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}