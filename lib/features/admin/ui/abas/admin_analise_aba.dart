import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/controller/dashboard_controller.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';
import 'package:proj_nape/features/dashboard/model/pagamento_funcionario.dart';
import 'package:proj_nape/repositories/venda_repository.dart';
import 'package:proj_nape/repositories/despesa_repository.dart';
import 'package:proj_nape/repositories/funcionario_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

enum _Periodo { semana, mes, custom }

extension _PeriodoLabel on _Periodo {
  String get label {
    switch (this) {
      case _Periodo.semana: return 'Esta semana';
      case _Periodo.mes:    return 'Este mês';
      case _Periodo.custom: return 'Personalizado';
    }
  }
}

class AdminAnaliseAba extends StatefulWidget {
  final String userId;

  const AdminAnaliseAba({super.key, required this.userId});

  @override
  State<AdminAnaliseAba> createState() => _AdminAnaliseAbaState();
}

class _AdminAnaliseAbaState extends State<AdminAnaliseAba> {
  final _vendaRepo = VendaRepository();
  final _despesaRepo = DespesaRepository();
  final _funcionarioRepo = FuncionarioRepository();

  List<Venda> _vendas = [];
  List<Despesa> _despesas = [];
  List<PagamentoFuncionario> _pagamentos = [];
  bool _carregando = true;

  _Periodo _periodoSelecionado = _Periodo.mes;
  DateTimeRange? _periodoCustom;

  bool _graficoVG = false;
  bool _graficoCO = false;
  bool _custosExpandido = false;

  _Periodo _comparacaoA = _Periodo.mes;
  _Periodo _comparacaoB = _Periodo.mes;
  DateTimeRange? _customA;
  DateTimeRange? _customB;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      final results = await Future.wait([
        _vendaRepo.buscarVendas(userId: widget.userId),
        _despesaRepo.buscarDespesas(userId: widget.userId),
        _funcionarioRepo.buscarPagamentos(userId: widget.userId),
      ]);
      setState(() {
        _vendas = results[0] as List<Venda>;
        _despesas = results[1] as List<Despesa>;
        _pagamentos = results[2] as List<PagamentoFuncionario>;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      debugPrint('Erro ao carregar dados: $e');
    }
  }

  // ── Período ────────────────────────────────────────────────────────────────

  DateTimeRange _intervaloParaPeriodo(_Periodo p, DateTimeRange? custom) {
    final agora = DateTime.now();
    switch (p) {
      case _Periodo.semana:
        return DateTimeRange(
          start: agora.subtract(Duration(days: agora.weekday - 1)),
          end: agora,
        );
      case _Periodo.mes:
        return DateTimeRange(
          start: DateTime(agora.year, agora.month, 1),
          end: agora,
        );
      case _Periodo.custom:
        return custom ?? DateTimeRange(start: agora, end: agora);
    }
  }

  DateTimeRange get _intervalo =>
      _intervaloParaPeriodo(_periodoSelecionado, _periodoCustom);

  String get _labelAtivo {
    if (_periodoSelecionado == _Periodo.custom && _periodoCustom != null) {
      final fmt = DateFormat('d MMM', 'pt_BR');
      return '${fmt.format(_periodoCustom!.start)} a ${fmt.format(_periodoCustom!.end)}';
    }
    return _periodoSelecionado.label;
  }

  String _labelPeriodo(_Periodo p, DateTimeRange? custom) {
    if (p == _Periodo.custom && custom != null) {
      final fmt = DateFormat('d MMM', 'pt_BR');
      return '${fmt.format(custom.start)} a ${fmt.format(custom.end)}';
    }
    return p.label;
  }

  Future<void> _abrirCalendario({
    required Function(DateTimeRange) onPicked,
    DateTimeRange? inicial,
  }) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: inicial,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFC2463C),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<_Periodo?> _abrirSeletorPeriodo(_Periodo atual) {
    final opcoes = _Periodo.values.where((p) => p != _Periodo.custom).toList();

    return showModalBottomSheet<_Periodo>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...opcoes.map((p) => ListTile(
                  leading: Icon(
                    Icons.check,
                    color: atual == p
                        ? const Color(0xFFC2463C)
                        : Colors.transparent,
                    size: 18,
                  ),
                  title: Text(
                    p.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: atual == p
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: atual == p
                          ? const Color(0xFFC2463C)
                          : Colors.black87,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, p),
                )),
            ListTile(
              leading: Icon(
                atual == _Periodo.custom
                    ? Icons.check
                    : Icons.calendar_month_outlined,
                color: atual == _Periodo.custom
                    ? const Color(0xFFC2463C)
                    : Colors.black54,
                size: 18,
              ),
              title: Text(
                'Personalizado',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: atual == _Periodo.custom
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: atual == _Periodo.custom
                      ? const Color(0xFFC2463C)
                      : Colors.black87,
                ),
              ),
              onTap: () => Navigator.pop(context, _Periodo.custom),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Cálculos ───────────────────────────────────────────────────────────────

  Map<String, double> _calcularCustos(
      List<Despesa> despesas,
      List<PagamentoFuncionario> pagamentos,
      DateTimeRange intervalo) {
    double cmv = 0, cmo = 0, fixo = 0, outros = 0;
    final tiposMO = {'salario', 'comissao', 'bonus', 'diaria', 'ferias', 'decimo'};
    final competencia =
        '${intervalo.start.year}-${intervalo.start.month.toString().padLeft(2, '0')}';

    for (final d in despesas) {
      if (d.data.isBefore(intervalo.start) || d.data.isAfter(intervalo.end)) continue;
      switch (d.tipo) {
        case 'ingredientes': cmv += d.valor; break;
        case 'fixo':         fixo += d.valor; break;
        case 'mao_de_obra':  cmo  += d.valor; break;
        default:             outros += d.valor;
      }
    }

    for (final p in pagamentos) {
      if (p.competencia != competencia || p.status == 'cancelado') continue;
      if (tiposMO.contains(p.tipo)) cmo += p.valor;
    }

    return {'cmv': cmv, 'cmo': cmo, 'fixo': fixo, 'outros': outros};
  }

  List<MapEntry<String, double>> _topProdutos(
      List<Venda> vendas, DateTimeRange intervalo) {
    final Map<String, double> porProduto = {};
    for (final v in vendas) {
      if (v.data.isBefore(intervalo.start) || v.data.isAfter(intervalo.end)) continue;
      porProduto[v.nomeProdutoSnapshot] =
          (porProduto[v.nomeProdutoSnapshot] ?? 0) + v.valorTotal;
    }
    final lista = porProduto.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return lista.take(3).toList();
  }

  Map<DateTime, double> _agruparPorDia(
      List<Venda> vendas,
      List<Despesa> despesas,
      DateTimeRange intervalo,
      String tipo) {
    final Map<DateTime, double> resultado = {};
    var atual = DateTime(
        intervalo.start.year, intervalo.start.month, intervalo.start.day);
    final fim = DateTime(
        intervalo.end.year, intervalo.end.month, intervalo.end.day);

    while (!atual.isAfter(fim)) {
      resultado[atual] = 0;
      atual = atual.add(const Duration(days: 1));
    }

    if (tipo == 'faturamento') {
      for (final v in vendas) {
        if (v.data.isBefore(intervalo.start) || v.data.isAfter(intervalo.end)) continue;
        final dia = DateTime(v.data.year, v.data.month, v.data.day);
        resultado[dia] = (resultado[dia] ?? 0) + v.valorTotal;
      }
    } else {
      for (final d in despesas) {
        if (d.data.isBefore(intervalo.start) || d.data.isAfter(intervalo.end)) continue;
        final dia = DateTime(d.data.year, d.data.month, d.data.day);
        resultado[dia] = (resultado[dia] ?? 0) + d.valor;
      }
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFC2463C)));
    }

    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final intervalo = _intervalo;

    final vendasFiltradas = _vendas
        .where((v) =>
            !v.data.isBefore(intervalo.start) &&
            !v.data.isAfter(intervalo.end))
        .toList();

    final despesasFiltradas = _despesas
        .where((d) =>
            !d.data.isBefore(intervalo.start) &&
            !d.data.isAfter(intervalo.end))
        .toList();

    final controller = DashboardController(
      vendas: vendasFiltradas,
      despesas: despesasFiltradas,
    );

    final custos = _calcularCustos(_despesas, _pagamentos, intervalo);
    final cmv = custos['cmv']!;
    final cmo = custos['cmo']!;
    final fixo = custos['fixo']!;
    final outros = custos['outros']!;
    final totalCustos = cmv + cmo + fixo + outros;

    final receitaBruta = controller.faturamentoTotal;
    final lucro = receitaBruta - totalCustos;
    final margemPerc = receitaBruta > 0 ? (lucro / receitaBruta) * 100 : 0.0;
    final cmvPerc = receitaBruta > 0 ? (cmv / receitaBruta) * 100 : 0.0;
    final cmoPerc = receitaBruta > 0 ? (cmo / receitaBruta) * 100 : 0.0;
    final emPrejuizo = lucro < 0;

    final topProdutos = _topProdutos(_vendas, intervalo);

    final dadosFat = _agruparPorDia(_vendas, _despesas, intervalo, 'faturamento');
    final dadosCus = _agruparPorDia(_vendas, _despesas, intervalo, 'custos');
    final dias = dadosFat.keys.toList()..sort();

    // Comparação
    final intervaloA = _intervaloParaPeriodo(_comparacaoA, _customA);
    final intervaloB = _intervaloParaPeriodo(_comparacaoB, _customB);

    final vendasA = _vendas.where((v) =>
        !v.data.isBefore(intervaloA.start) && !v.data.isAfter(intervaloA.end)).toList();
    final despesasA = _despesas.where((d) =>
        !d.data.isBefore(intervaloA.start) && !d.data.isAfter(intervaloA.end)).toList();
    final controllerA = DashboardController(vendas: vendasA, despesas: despesasA);
    final custosA = _calcularCustos(_despesas, _pagamentos, intervaloA);
    final totalCustosA = custosA.values.fold(0.0, (s, v) => s + v);
    final lucroA = controllerA.faturamentoTotal - totalCustosA;
    final margemA = controllerA.faturamentoTotal > 0
        ? (lucroA / controllerA.faturamentoTotal) * 100 : 0.0;

    final vendasB = _vendas.where((v) =>
        !v.data.isBefore(intervaloB.start) && !v.data.isAfter(intervaloB.end)).toList();
    final despesasB = _despesas.where((d) =>
        !d.data.isBefore(intervaloB.start) && !d.data.isAfter(intervaloB.end)).toList();
    final controllerB = DashboardController(vendas: vendasB, despesas: despesasB);
    final custosB = _calcularCustos(_despesas, _pagamentos, intervaloB);
    final totalCustosB = custosB.values.fold(0.0, (s, v) => s + v);
    final lucroB = controllerB.faturamentoTotal - totalCustosB;
    final margemB = controllerB.faturamentoTotal > 0
        ? (lucroB / controllerB.faturamentoTotal) * 100 : 0.0;

    final ticketMedio = vendasFiltradas.isNotEmpty
        ? receitaBruta / vendasFiltradas.length
        : 0.0;
    final margemPorVenda = vendasFiltradas.isNotEmpty
        ? (receitaBruta - totalCustos) / vendasFiltradas.length
        : 0.0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [

        // ── Seletor de período ────────────────────────────────────────────
        GestureDetector(
          onTap: () async {
            final resultado = await _abrirSeletorPeriodo(_periodoSelecionado);
            if (resultado == null) return;
            if (resultado == _Periodo.custom) {
              await _abrirCalendario(
                onPicked: (r) => setState(() {
                  _periodoCustom = r;
                  _periodoSelecionado = _Periodo.custom;
                }),
                inicial: _periodoCustom,
              );
            } else {
              setState(() => _periodoSelecionado = resultado);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_month_outlined,
                    size: 16, color: Color(0xFFC2463C)),
                const SizedBox(width: 8),
                Text(
                  _labelAtivo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down,
                    size: 18, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── 1. VISÃO GERAL ────────────────────────────────────────────────
        _Secao(
          titulo: 'Visão Geral',
          acaoDireita: _BotaoVerGrafico(
            visivel: _graficoVG,
            onTap: () => setState(() => _graficoVG = !_graficoVG),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _CardMetrica(
                    label: emPrejuizo ? 'Prejuízo' : 'Lucro',
                    valor: fmt.format(lucro.abs()),
                    cor: emPrejuizo
                        ? const Color(0xFFC2463C)
                        : const Color(0xFF3E8E41),
                  ),
                  const SizedBox(width: 12),
                  _CardMetrica(
                    label: 'Margem',
                    valor: '${margemPerc.toStringAsFixed(1)}%',
                    cor: margemPerc >= 20
                        ? const Color(0xFF3E8E41)
                        : margemPerc >= 10
                            ? const Color(0xFFFFB300)
                            : const Color(0xFFC2463C),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _CardMetrica(
                    label: 'Faturamento',
                    valor: fmt.format(receitaBruta),
                    cor: const Color(0xFF2D74C4),
                  ),
                  const SizedBox(width: 12),
                  _CardMetrica(
                    label: 'Total de custos',
                    valor: fmt.format(totalCustos),
                    cor: const Color(0xFFC2463C),
                  ),
                ],
              ),
              if (_graficoVG && dias.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Grafico(dadosFat: dadosFat, dadosCus: dadosCus, dias: dias),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── 2. CUSTOS OPERACIONAIS ────────────────────────────────────────
        _Secao(
          titulo: 'Custos Operacionais',
          acaoDireita: _BotaoVerGrafico(
            visivel: _graficoCO,
            onTap: () => setState(() => _graficoCO = !_graficoCO),
          ),
          child: Column(
            children: [
              _LinhaCusto(
                sigla: 'CMV',
                nomeCompleto: 'Custo da Mercadoria Vendida',
                valor: fmt.format(cmv),
                percentual: cmvPerc,
                meta: 35,
              ),
              const _Divisor(),
              _LinhaCusto(
                sigla: 'CMO',
                nomeCompleto: 'Custo da Mão de Obra',
                valor: fmt.format(cmo),
                percentual: cmoPerc,
                meta: 30,
              ),
              const _Divisor(),
              _LinhaSimples(label: 'Custos fixos', valor: fmt.format(fixo)),
              const _Divisor(),
              _LinhaSimples(label: 'Outros', valor: fmt.format(outros)),

              const SizedBox(height: 12),
              GestureDetector(
                onTap: () =>
                    setState(() => _custosExpandido = !_custosExpandido),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _custosExpandido ? 'Ver menos' : 'Ver análise detalhada',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC2463C),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _custosExpandido
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: const Color(0xFFC2463C),
                    ),
                  ],
                ),
              ),

              if (_custosExpandido) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _DadoCircurgico(
                  label: 'Custos como % do faturamento',
                  valor: receitaBruta > 0
                      ? '${(totalCustos / receitaBruta * 100).toStringAsFixed(1)}%'
                      : '—',
                ),
                const SizedBox(height: 8),
                _DadoCircurgico(
                  label: 'CMV + CMO (custo direto)',
                  valor: fmt.format(cmv + cmo),
                  subvalor: receitaBruta > 0
                      ? '${((cmv + cmo) / receitaBruta * 100).toStringAsFixed(1)}% do faturamento'
                      : null,
                ),
                const SizedBox(height: 8),
                _DadoCircurgico(
                  label: 'Custo fixo por dia',
                  valor: intervalo.duration.inDays > 0
                      ? fmt.format(fixo / intervalo.duration.inDays)
                      : '—',
                ),
              ],

              if (_graficoCO) ...[
                const SizedBox(height: 16),
                _GraficoCustos(custos: custos),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── 3. DESEMPENHO ─────────────────────────────────────────────────
        _Secao(
          titulo: 'Desempenho',
          child: Column(
            children: [
              Row(
                children: [
                  _CardMetrica(
                    label: 'Ticket médio',
                    valor: fmt.format(ticketMedio),
                    cor: const Color(0xFF2D74C4),
                  ),
                  const SizedBox(width: 12),
                  _CardMetrica(
                    label: 'Margem por venda',
                    valor: fmt.format(margemPorVenda),
                    cor: margemPorVenda >= 0
                        ? const Color(0xFF3E8E41)
                        : const Color(0xFFC2463C),
                  ),
                ],
              ),
              if (topProdutos.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Top produtos',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...topProdutos.asMap().entries.map((e) {
                  final posicao = e.key + 1;
                  final produto = e.value;
                  final perc = receitaBruta > 0
                      ? (produto.value / receitaBruta * 100).toStringAsFixed(1)
                      : '0';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D74C4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '$posicao',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D74C4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            produto.key,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$perc%',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black38),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fmt.format(produto.value),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D74C4),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── 4. COMPARAÇÃO ─────────────────────────────────────────────────
        _Secao(
          titulo: 'Comparação',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SeletorComparacao(
                      label: 'Período A',
                      valor: _labelPeriodo(_comparacaoA, _customA),
                      onTap: () async {
                        final r = await _abrirSeletorPeriodo(_comparacaoA);
                        if (r == null) return;
                        if (r == _Periodo.custom) {
                          await _abrirCalendario(
                            onPicked: (picked) => setState(() {
                              _customA = picked;
                              _comparacaoA = _Periodo.custom;
                            }),
                            inicial: _customA,
                          );
                        } else {
                          setState(() => _comparacaoA = r);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SeletorComparacao(
                      label: 'Período B',
                      valor: _labelPeriodo(_comparacaoB, _customB),
                      onTap: () async {
                        final r = await _abrirSeletorPeriodo(_comparacaoB);
                        if (r == null) return;
                        if (r == _Periodo.custom) {
                          await _abrirCalendario(
                            onPicked: (picked) => setState(() {
                              _customB = picked;
                              _comparacaoB = _Periodo.custom;
                            }),
                            inicial: _customB,
                          );
                        } else {
                          setState(() => _comparacaoB = r);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _LinhaComparacao(
                label: 'Faturamento',
                valorA: fmt.format(controllerA.faturamentoTotal),
                valorB: fmt.format(controllerB.faturamentoTotal),
                variacaoPerc: _variacao(
                    controllerA.faturamentoTotal, controllerB.faturamentoTotal),
              ),
              const _Divisor(),
              _LinhaComparacao(
                label: 'Custos',
                valorA: fmt.format(totalCustosA),
                valorB: fmt.format(totalCustosB),
                variacaoPerc: _variacao(totalCustosA, totalCustosB),
                inverterCor: true,
              ),
              const _Divisor(),
              _LinhaComparacao(
                label: 'Lucro',
                valorA: fmt.format(lucroA),
                valorB: fmt.format(lucroB),
                variacaoPerc: _variacao(lucroA, lucroB),
              ),
              const _Divisor(),
              _LinhaComparacao(
                label: 'Margem',
                valorA: '${margemA.toStringAsFixed(1)}%',
                valorB: '${margemB.toStringAsFixed(1)}%',
                variacaoPerc: _variacao(margemA, margemB),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  double _variacao(double a, double b) {
    if (a == 0) return 0;
    return ((b - a) / a.abs()) * 100;
  }
}

// ── WIDGETS ───────────────────────────────────────────────────────────────────

class _Secao extends StatelessWidget {
  final String titulo;
  final Widget child;
  final Widget? acaoDireita;

  const _Secao({
    required this.titulo,
    required this.child,
    this.acaoDireita,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (acaoDireita != null) acaoDireita!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _BotaoVerGrafico extends StatelessWidget {
  final bool visivel;
  final VoidCallback onTap;

  const _BotaoVerGrafico({required this.visivel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: visivel
              ? const Color(0xFFC2463C)
              : const Color(0xFFC2463C).withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart,
                size: 14,
                color: visivel ? Colors.white : const Color(0xFFC2463C)),
            const SizedBox(width: 4),
            Text(
              visivel ? 'Ocultar' : 'Ver gráfico',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: visivel ? Colors.white : const Color(0xFFC2463C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardMetrica extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;

  const _CardMetrica({
    required this.label,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaCusto extends StatelessWidget {
  final String sigla;
  final String nomeCompleto;
  final String valor;
  final double percentual;
  final double meta;

  const _LinhaCusto({
    required this.sigla,
    required this.nomeCompleto,
    required this.valor,
    required this.percentual,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final dentro = percentual <= meta;
    final corMeta =
        dentro ? const Color(0xFF3E8E41) : const Color(0xFFC2463C);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: '$sigla ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '— $nomeCompleto',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      dentro
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_outlined,
                      size: 11,
                      color: corMeta,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Meta: < ${meta.toInt()}%',
                      style: TextStyle(fontSize: 11, color: corMeta),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC2463C),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: corMeta.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentual.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: corMeta,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinhaSimples extends StatelessWidget {
  final String label;
  final String valor;

  const _LinhaSimples({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC2463C),
            ),
          ),
        ],
      ),
    );
  }
}

class _DadoCircurgico extends StatelessWidget {
  final String label;
  final String valor;
  final String? subvalor;

  const _DadoCircurgico({
    required this.label,
    required this.valor,
    this.subvalor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              if (subvalor != null)
                Text(subvalor!,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black38)),
            ],
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _SeletorComparacao extends StatelessWidget {
  final String label;
  final String valor;
  final VoidCallback onTap;

  const _SeletorComparacao({
    required this.label,
    required this.valor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE9E4DF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black38,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down,
                    size: 16, color: Colors.grey.shade500),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaComparacao extends StatelessWidget {
  final String label;
  final String valorA;
  final String valorB;
  final double variacaoPerc;
  final bool inverterCor;

  const _LinhaComparacao({
    required this.label,
    required this.valorA,
    required this.valorB,
    required this.variacaoPerc,
    this.inverterCor = false,
  });

  @override
  Widget build(BuildContext context) {
    final subiu = variacaoPerc > 0;
    final cor = inverterCor
        ? (subiu ? const Color(0xFFC2463C) : const Color(0xFF3E8E41))
        : (subiu ? const Color(0xFF3E8E41) : const Color(0xFFC2463C));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valorA,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              valorB,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 60,
            child: variacaoPerc == 0
                ? const Text('—',
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                    textAlign: TextAlign.right)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        subiu ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: cor,
                      ),
                      Text(
                        '${variacaoPerc.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cor,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Divisor extends StatelessWidget {
  const _Divisor();

  @override
  Widget build(BuildContext context) =>
      Divider(color: Colors.grey.shade100, height: 1);
}

class _Grafico extends StatelessWidget {
  final Map<DateTime, double> dadosFat;
  final Map<DateTime, double> dadosCus;
  final List<DateTime> dias;

  const _Grafico({
    required this.dadosFat,
    required this.dadosCus,
    required this.dias,
  });

  @override
  Widget build(BuildContext context) {
    final fmtDia = DateFormat('dd/MM', 'pt_BR');
    final barWidth = dias.length <= 3
        ? 16.0
        : dias.length <= 7
            ? 10.0
            : 5.0;

    return Column(
      children: [
        Row(
          children: [
            _Legenda(cor: const Color(0xFF2D74C4), label: 'Faturamento'),
            const SizedBox(width: 12),
            _Legenda(cor: const Color(0xFFC2463C), label: 'Custos'),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade100, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= dias.length) {
                        return const SizedBox.shrink();
                      }
                      final intervalo =
                          dias.length <= 7 ? 1 : (dias.length / 5).ceil();
                      if (idx % intervalo != 0) return const SizedBox.shrink();
                      return Text(
                        fmtDia.format(dias[idx]),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black38),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: dias.asMap().entries.map((e) {
                final idx = e.key;
                final dia = e.value;
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: dadosFat[dia] ?? 0,
                      color: const Color(0xFF2D74C4),
                      width: barWidth,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    BarChartRodData(
                      toY: dadosCus[dia] ?? 0,
                      color: const Color(0xFFC2463C),
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
    );
  }
}

class _GraficoCustos extends StatelessWidget {
  final Map<String, double> custos;

  const _GraficoCustos({required this.custos});

  @override
  Widget build(BuildContext context) {
    final total = custos.values.fold(0.0, (s, v) => s + v);
    if (total == 0) return const SizedBox.shrink();

    final itens = [
      _ItemBarra('CMV', custos['cmv']!, const Color(0xFFC2463C)),
      _ItemBarra('CMO', custos['cmo']!, const Color(0xFF2D74C4)),
      _ItemBarra('Fixos', custos['fixo']!, const Color(0xFFFFB300)),
      _ItemBarra('Outros', custos['outros']!, Colors.grey),
    ].where((i) => i.valor > 0).toList();

    return Column(
      children: [
        const SizedBox(height: 8),
        ...itens.map((item) {
          final perc = item.valor / total * 100;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.cor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.label,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: perc / 100,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(item.cor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${perc.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: item.cor,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ItemBarra {
  final String label;
  final double valor;
  final Color cor;
  const _ItemBarra(this.label, this.valor, this.cor);
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
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}