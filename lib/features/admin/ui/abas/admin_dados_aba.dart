import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proj_nape/features/dashboard/controller/dashboard_controller.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';
import 'package:proj_nape/repositories/despesa_repository.dart';
import 'package:proj_nape/repositories/venda_repository.dart';
import 'package:intl/intl.dart';

enum _Periodo { hoje, ontem, semana, mes, custom }

extension _PeriodoLabel on _Periodo {
  String get label {
    switch (this) {
      case _Periodo.hoje:   return 'Hoje';
      case _Periodo.ontem:  return 'Ontem';
      case _Periodo.semana: return 'Esta semana';
      case _Periodo.mes:    return 'Este mês';
      case _Periodo.custom: return 'Personalizado';
    }
  }
}

class AdminDadosAba extends StatefulWidget {
  final String userId;

  const AdminDadosAba({super.key, required this.userId});

  @override
  State<AdminDadosAba> createState() => _AdminDadosAbaState();
}

class _AdminDadosAbaState extends State<AdminDadosAba>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _vendaRepo = VendaRepository();
  final _despesaRepo = DespesaRepository();

  List<Venda> _vendas = [];
  List<Despesa> _despesas = [];
  bool _carregando = true;
  bool _tabelaVisivel = false;

  _Periodo _periodoSelecionado = _Periodo.mes;
  DateTimeRange? _periodoCustom;
  String _busca = '';
  String _categoriaSelecionada = 'Todas';
  int _paginaAtual = 0;
  final int _itensPorPagina = 50;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {
          _busca = '';
          _categoriaSelecionada = 'Todas';
          _paginaAtual = 0;
        }));
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      final vendas = await _vendaRepo.buscarVendas(userId: widget.userId);
      final despesas = await _despesaRepo.buscarDespesas(userId: widget.userId);
      setState(() {
        _vendas = vendas;
        _despesas = despesas;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  DateTimeRange get _intervalo {
    final agora = DateTime.now();
    switch (_periodoSelecionado) {
      case _Periodo.hoje:
        return DateTimeRange(
          start: DateTime(agora.year, agora.month, agora.day),
          end: agora,
        );
      case _Periodo.ontem:
        final ontem = agora.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: DateTime(ontem.year, ontem.month, ontem.day),
          end: DateTime(ontem.year, ontem.month, ontem.day, 23, 59, 59),
        );
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
        return _periodoCustom ?? DateTimeRange(start: agora, end: agora);
    }
  }

  String get _labelPeriodo {
    if (_periodoSelecionado == _Periodo.custom && _periodoCustom != null) {
      final fmt = DateFormat('d MMM', 'pt_BR');
      return '${fmt.format(_periodoCustom!.start)} a ${fmt.format(_periodoCustom!.end)}';
    }
    return _periodoSelecionado.label;
  }

  Future<void> _abrirSeletorPeriodo() async {
    final opcoes = _Periodo.values.where((p) => p != _Periodo.custom).toList();

    final resultado = await showModalBottomSheet<_Periodo>(
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
                    color: _periodoSelecionado == p
                        ? const Color(0xFFC2463C)
                        : Colors.transparent,
                    size: 18,
                  ),
                  title: Text(
                    p.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _periodoSelecionado == p
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: _periodoSelecionado == p
                          ? const Color(0xFFC2463C)
                          : Colors.black87,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, p),
                )),
            ListTile(
              leading: Icon(
                _periodoSelecionado == _Periodo.custom
                    ? Icons.check
                    : Icons.calendar_month_outlined,
                color: _periodoSelecionado == _Periodo.custom
                    ? const Color(0xFFC2463C)
                    : Colors.black54,
                size: 18,
              ),
              title: Text(
                _periodoSelecionado == _Periodo.custom
                    ? _labelPeriodo
                    : 'Personalizado',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: _periodoSelecionado == _Periodo.custom
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: _periodoSelecionado == _Periodo.custom
                      ? const Color(0xFFC2463C)
                      : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _abrirCalendario();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (resultado != null) {
      setState(() => _periodoSelecionado = resultado);
    }
  }

  Future<void> _abrirCalendario() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _periodoCustom,
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
    if (picked != null) {
      setState(() {
        _periodoCustom = picked;
        _periodoSelecionado = _Periodo.custom;
      });
    }
  }

  List<Venda> get _vendasFiltradas {
    final intervalo = _intervalo;
    return _vendas.where((v) {
      final periodoOk = !v.data.isBefore(intervalo.start) &&
          !v.data.isAfter(intervalo.end);
      final buscaOk = _busca.isEmpty ||
          v.nomeProdutoSnapshot.toLowerCase().contains(_busca.toLowerCase()) ||
          v.categoriaSnapshot.toLowerCase().contains(_busca.toLowerCase());
      final categoriaOk = _categoriaSelecionada == 'Todas' ||
          v.categoriaSnapshot == _categoriaSelecionada;
      return periodoOk && buscaOk && categoriaOk;
    }).toList();
  }

  List<Despesa> get _despesasFiltradas {
    final intervalo = _intervalo;
    return _despesas.where((d) {
      final periodoOk = !d.data.isBefore(intervalo.start) &&
          !d.data.isAfter(intervalo.end);
      final buscaOk = _busca.isEmpty ||
          d.descricao.toLowerCase().contains(_busca.toLowerCase()) ||
          d.categoria.toLowerCase().contains(_busca.toLowerCase());
      final categoriaOk = _categoriaSelecionada == 'Todas' ||
          d.categoria == _categoriaSelecionada;
      return periodoOk && buscaOk && categoriaOk;
    }).toList();
  }

  List<String> get _categoriasVendas => [
        'Todas',
        ..._vendasFiltradas.map((v) => v.categoriaSnapshot).toSet().toList()
      ];

  List<String> get _categoriasDespesas => [
        'Todas',
        ..._despesasFiltradas.map((d) => d.categoria).toSet().toList()
      ];

  List<T> _paginar<T>(List<T> lista) {
    final inicio = _paginaAtual * _itensPorPagina;
    final fim = (inicio + _itensPorPagina).clamp(0, lista.length);
    if (inicio >= lista.length) return [];
    return lista.sublist(inicio, fim);
  }

  Map<DateTime, double> _agruparPorDia(
      List<Venda> vendas, List<Despesa> despesas, String tipo) {
    final Map<DateTime, double> resultado = {};
    final intervalo = _intervalo;
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
        final dia = DateTime(v.data.year, v.data.month, v.data.day);
        resultado[dia] = (resultado[dia] ?? 0) + v.valorTotal;
      }
    } else if (tipo == 'custos') {
      for (final d in despesas) {
        final dia = DateTime(d.data.year, d.data.month, d.data.day);
        resultado[dia] = (resultado[dia] ?? 0) + d.valor;
      }
    } else {
      final fat = _agruparPorDia(vendas, despesas, 'faturamento');
      final cus = _agruparPorDia(vendas, despesas, 'custos');
      for (final dia in fat.keys) {
        resultado[dia] = (fat[dia] ?? 0) - (cus[dia] ?? 0);
      }
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final fmtData = DateFormat('dd/MM/yy', 'pt_BR');
    final fmtDia = DateFormat('dd/MM', 'pt_BR');

    final isVendas = _tabController.index == 0;
    final vendasFiltradas = _vendasFiltradas;
    final despesasFiltradas = _despesasFiltradas;
    final listaFiltrada = isVendas ? vendasFiltradas : despesasFiltradas;

    final controller = DashboardController(
      vendas: vendasFiltradas,
      despesas: despesasFiltradas,
    );

    final dadosFat = _agruparPorDia(vendasFiltradas, despesasFiltradas, 'faturamento');
    final dadosCus = _agruparPorDia(vendasFiltradas, despesasFiltradas, 'custos');
    final dadosLuc = _agruparPorDia(vendasFiltradas, despesasFiltradas, 'lucro');
    final dias = dadosFat.keys.toList()..sort();

    return _carregando
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFC2463C)))
        : ListView(
            children: [
              // ── Seletor de período ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: GestureDetector(
                  onTap: _abrirSeletorPeriodo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                          _labelPeriodo,
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
              ),

              const SizedBox(height: 16),

              // ── Cards resumo ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _CardResumo(
                      titulo: 'Faturamento',
                      valor: fmt.format(controller.faturamentoTotal),
                      cor: const Color(0xFF2D74C4),
                    ),
                    const SizedBox(width: 8),
                    _CardResumo(
                      titulo: 'Custos',
                      valor: fmt.format(controller.custosTotal),
                      cor: const Color(0xFFC2463C),
                    ),
                    const SizedBox(width: 8),
                    _CardResumo(
                      titulo: controller.lucro >= 0 ? 'Lucro' : 'Prejuízo',
                      valor: fmt.format(controller.lucro.abs()),
                      cor: controller.lucro >= 0
                          ? const Color(0xFF3E8E41)
                          : const Color(0xFFC2463C),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Gráfico ────────────────────────────────────────────────
              if (dias.isNotEmpty)
                Container(
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
                              final diasComDados = dias.where((d) =>
    (dadosFat[d] ?? 0) > 0 ||
    (dadosCus[d] ?? 0) > 0).length;
final barWidth = diasComDados <= 3
    ? 16.0
    : diasComDados <= 7
        ? 10.0
        : dias.length <= 7
            ? 8.0
            : 4.0;

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
                ),

              const SizedBox(height: 16),

              // ── Ver/Ocultar detalhes ───────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _tabelaVisivel = !_tabelaVisivel),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tabelaVisivel ? 'Ocultar detalhes' : 'Ver detalhes',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _tabelaVisivel
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Tabela ─────────────────────────────────────────────────
              if (_tabelaVisivel) ...[
                const SizedBox(height: 16),

                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFFC2463C),
                    labelColor: const Color(0xFFC2463C),
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Vendas'),
                      Tab(text: 'Despesas'),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  color: const Color(0xFFE9E4DF),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) => setState(() {
                          _busca = v;
                          _paginaAtual = 0;
                        }),
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          hintStyle: const TextStyle(
                              fontSize: 13, color: Colors.black38),
                          prefixIcon: const Icon(Icons.search,
                              size: 18, color: Colors.black38),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: (isVendas
                                  ? _categoriasVendas
                                  : _categoriasDespesas)
                              .map((cat) {
                            final sel = cat == _categoriaSelecionada;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _categoriaSelecionada = cat;
                                  _paginaAtual = 0;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? const Color(0xFFC2463C)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: sel
                                          ? const Color(0xFFC2463C)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: sel
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Text(
                    isVendas
                        ? '${vendasFiltradas.length} registros · Total ${fmt.format(vendasFiltradas.fold(0.0, (s, v) => s + v.valorTotal))}'
                        : '${despesasFiltradas.length} registros · Total ${fmt.format(despesasFiltradas.fold(0.0, (s, d) => s + d.valor))}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),

                Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _th('Data', 65),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _th(
                              isVendas ? 'Produto' : 'Descrição', null)),
                      const SizedBox(width: 8),
                      _th('Categ.', 70),
                      if (isVendas) ...[
                        const SizedBox(width: 8),
                        _th('Qtd', 30),
                      ],
                      const SizedBox(width: 8),
                      _th('Total', 65),
                      const SizedBox(width: 32),
                    ],
                  ),
                ),

                if (listaFiltrada.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Nenhum registro encontrado',
                        style: TextStyle(color: Colors.black38),
                      ),
                    ),
                  )
                else
                  ...(_paginar(listaFiltrada).map((item) {
                    if (isVendas) {
                      final v = item as Venda;
                      return _LinhaVenda(
                        venda: v,
                        fmt: fmt,
                        fmtData: fmtData,
                        onDeletar: () async {
                          await _vendaRepo.deletarVenda(v.id);
                          _carregarDados();
                        },
                      );
                    } else {
                      final d = item as Despesa;
                      return _LinhaDespesa(
                        despesa: d,
                        fmt: fmt,
                        fmtData: fmtData,
                        onDeletar: () async {
                          await _despesaRepo.deletarDespesa(d.id);
                          _carregarDados();
                        },
                      );
                    }
                  })),

                if ((listaFiltrada.length / _itensPorPagina).ceil() > 1)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_paginaAtual * _itensPorPagina + 1}–${((_paginaAtual + 1) * _itensPorPagina).clamp(0, listaFiltrada.length)} de ${listaFiltrada.length}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 16),
                              onPressed: _paginaAtual > 0
                                  ? () => setState(() => _paginaAtual--)
                                  : null,
                              color: const Color(0xFFC2463C),
                            ),
                            Text(
                              '${_paginaAtual + 1}/${(listaFiltrada.length / _itensPorPagina).ceil()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, size: 16),
                              onPressed: _paginaAtual < (listaFiltrada.length / _itensPorPagina).ceil() - 1
    ? () => setState(() => _paginaAtual++)
    : null,
                              color: const Color(0xFFC2463C),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC2463C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.add,
                              size: 18, color: Colors.white),
                          label: const Text('Adicionar',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black54,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Exportar CSV'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ],
          );
  }

  Widget _th(String texto, double? largura) {
    return largura != null
        ? SizedBox(
            width: largura,
            child: Text(texto,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black45)),
          )
        : Text(texto,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black45));
  }
}

// ── Card Resumo ───────────────────────────────────────────────────────────────

class _CardResumo extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color cor;

  const _CardResumo({
    required this.titulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black38,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 13,
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

// ── Legenda ───────────────────────────────────────────────────────────────────

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

// ── Linha Venda ───────────────────────────────────────────────────────────────

class _LinhaVenda extends StatelessWidget {
  final Venda venda;
  final NumberFormat fmt;
  final DateFormat fmtData;
  final VoidCallback onDeletar;

  const _LinhaVenda({
    required this.venda,
    required this.fmt,
    required this.fmtData,
    required this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(fmtData.format(venda.data),
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              venda.nomeProdutoSnapshot,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(venda.categoriaSnapshot,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text('${venda.quantidade}x',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 65,
            child: Text(
              fmt.format(venda.valorTotal),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D74C4),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: Colors.black38),
            onSelected: (value) {
              if (value == 'deletar') _confirmarDelecao(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 16, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Editar', style: TextStyle(fontSize: 13)),
                ]),
              ),
              const PopupMenuItem(
                value: 'deletar',
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 16, color: Color(0xFFC2463C)),
                  SizedBox(width: 8),
                  Text('Deletar',
                      style: TextStyle(fontSize: 13, color: Color(0xFFC2463C))),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmarDelecao(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Deletar venda'),
        content: Text(
            'Deseja deletar a venda de "${venda.nomeProdutoSnapshot}"?\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.black54))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDeletar();
              },
              child: const Text('Deletar',
                  style: TextStyle(color: Color(0xFFC2463C)))),
        ],
      ),
    );
  }
}

// ── Linha Despesa ─────────────────────────────────────────────────────────────

class _LinhaDespesa extends StatelessWidget {
  final Despesa despesa;
  final NumberFormat fmt;
  final DateFormat fmtData;
  final VoidCallback onDeletar;

  const _LinhaDespesa({
    required this.despesa,
    required this.fmt,
    required this.fmtData,
    required this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(fmtData.format(despesa.data),
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              despesa.descricao,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(despesa.categoria,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 65,
            child: Text(
              fmt.format(despesa.valor),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC2463C),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: Colors.black38),
            onSelected: (value) {
              if (value == 'deletar') _confirmarDelecao(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 16, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Editar', style: TextStyle(fontSize: 13)),
                ]),
              ),
              const PopupMenuItem(
                value: 'deletar',
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 16, color: Color(0xFFC2463C)),
                  SizedBox(width: 8),
                  Text('Deletar',
                      style: TextStyle(fontSize: 13, color: Color(0xFFC2463C))),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmarDelecao(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Deletar despesa'),
        content: Text(
            'Deseja deletar "${despesa.descricao}"?\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.black54))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDeletar();
              },
              child: const Text('Deletar',
                  style: TextStyle(color: Color(0xFFC2463C)))),
        ],
      ),
    );
  }
}