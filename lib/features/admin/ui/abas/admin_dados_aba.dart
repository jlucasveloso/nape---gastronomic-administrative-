import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proj_nape/features/admin/ui/abas/widgets/admin_cards_resumo.dart';
import 'package:proj_nape/features/admin/ui/abas/widgets/admin_grafico_barras.dart';
import 'package:proj_nape/features/admin/ui/abas/widgets/admin_tabela_despesas.dart';
import 'package:proj_nape/features/admin/ui/abas/widgets/admin_tabela_vendas.dart';
import 'package:proj_nape/features/dashboard/controller/dashboard_controller.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';
import 'package:proj_nape/repositories/cardapio_repository.dart';
import 'package:proj_nape/repositories/despesa_repository.dart';
import 'package:proj_nape/repositories/venda_repository.dart';

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
  final _cardapioRepo = CardapioRepository();

  List<Venda> _vendas = [];
  List<Despesa> _despesas = [];
  List<ProdutoCardapio> _cardapio = [];
  bool _carregando = true;
  bool _tabelaVisivel = false;

  // Filtros
  _Periodo _periodoSelecionado = _Periodo.mes;
  DateTimeRange? _periodoCustom;
  String _busca = '';
  String _categoriaSelecionada = 'Todas';
  double? _valorMin;
  double? _valorMax;

  // Paginação
  int _paginaAtual = 0;
  final int _itensPorPagina = 50;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {
          _busca = '';
          _categoriaSelecionada = 'Todas';
          _valorMin = null;
          _valorMax = null;
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
      final results = await Future.wait([
        _vendaRepo.buscarVendas(userId: widget.userId),
        _despesaRepo.buscarDespesas(userId: widget.userId),
        _cardapioRepo.buscarProdutos(userId: widget.userId),
      ]);
      setState(() {
        _vendas = results[0] as List<Venda>;
        _despesas = results[1] as List<Despesa>;
        _cardapio = results[2] as List<ProdutoCardapio>;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      debugPrint('Erro ao carregar dados: $e');
    }
  }

  // ── Período ────────────────────────────────────────────────────────────────

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
    final opcoes =
        _Periodo.values.where((p) => p != _Periodo.custom).toList();

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
      setState(() {
        _periodoSelecionado = resultado;
        _paginaAtual = 0;
      });
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
        _paginaAtual = 0;
      });
    }
  }

  // ── Filtros ────────────────────────────────────────────────────────────────

  List<Venda> get _vendasFiltradas {
    final intervalo = _intervalo;
    return _vendas.where((v) {
      final periodoOk = !v.data.isBefore(intervalo.start) &&
          !v.data.isAfter(intervalo.end);
      final buscaOk = _busca.isEmpty ||
          v.nomeProdutoSnapshot
              .toLowerCase()
              .contains(_busca.toLowerCase()) ||
          v.categoriaSnapshot
              .toLowerCase()
              .contains(_busca.toLowerCase());
      final categoriaOk = _categoriaSelecionada == 'Todas' ||
          v.categoriaSnapshot == _categoriaSelecionada;
      final valorMinOk =
          _valorMin == null || v.valorTotal >= _valorMin!;
      final valorMaxOk =
          _valorMax == null || v.valorTotal <= _valorMax!;
      return periodoOk && buscaOk && categoriaOk && valorMinOk && valorMaxOk;
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
      final valorMinOk = _valorMin == null || d.valor >= _valorMin!;
      final valorMaxOk = _valorMax == null || d.valor <= _valorMax!;
      return periodoOk && buscaOk && categoriaOk && valorMinOk && valorMaxOk;
    }).toList();
  }

  List<String> get _categoriasVendas => [
        'Todas',
        ..._vendasFiltradas
            .map((v) => v.categoriaSnapshot)
            .toSet()
            .toList()
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

  // ── Gráfico ────────────────────────────────────────────────────────────────

  Map<DateTime, double> _agruparPorDia(
      List<Venda> vendas, List<Despesa> despesas, String tipo) {
    final Map<DateTime, double> resultado = {};
    final intervalo = _intervalo;
    var atual = DateTime(intervalo.start.year, intervalo.start.month,
        intervalo.start.day);
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

  // ── Filtro de valor ────────────────────────────────────────────────────────

  void _abrirFiltroValor() {
    final minController =
        TextEditingController(text: _valorMin?.toStringAsFixed(0) ?? '');
    final maxController =
        TextEditingController(text: _valorMax?.toStringAsFixed(0) ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar por valor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Valor mínimo',
                      prefixText: 'R\$ ',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFC2463C)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: maxController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Valor máximo',
                      prefixText: 'R\$ ',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFC2463C)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _valorMin = null;
                        _valorMax = null;
                      });
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black54,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _valorMin = double.tryParse(
                            minController.text.replaceAll(',', '.'));
                        _valorMax = double.tryParse(
                            maxController.text.replaceAll(',', '.'));
                        _paginaAtual = 0;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2463C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Aplicar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final fmtData = DateFormat('dd/MM/yy', 'pt_BR');

    final isVendas = _tabController.index == 0;
    final vendasFiltradas = _vendasFiltradas;
    final despesasFiltradas = _despesasFiltradas;
    final listaFiltrada =
        isVendas ? vendasFiltradas : despesasFiltradas;

    final controller = DashboardController(
      vendas: vendasFiltradas,
      despesas: despesasFiltradas,
    );

    final dadosFat =
        _agruparPorDia(vendasFiltradas, despesasFiltradas, 'faturamento');
    final dadosCus =
        _agruparPorDia(vendasFiltradas, despesasFiltradas, 'custos');
    final dadosLuc =
        _agruparPorDia(vendasFiltradas, despesasFiltradas, 'lucro');
    final dias = dadosFat.keys.toList()..sort();

    final temFiltroValor = _valorMin != null || _valorMax != null;

    return _carregando
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFC2463C)))
        : ListView(
            children: [
              // ── Seletor de período ───────────────────────────────────────
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

              // ── Cards resumo ─────────────────────────────────────────────
              AdminCardsResumo(
                faturamento: fmt.format(controller.faturamentoTotal),
                custos: fmt.format(controller.custosTotal),
                lucro: fmt.format(controller.lucro.abs()),
                emPrejuizo: controller.lucro < 0,
              ),

              const SizedBox(height: 16),

              // ── Gráfico ──────────────────────────────────────────────────
              if (dias.isNotEmpty)
                AdminGraficoBarras(
                  dadosFat: dadosFat,
                  dadosCus: dadosCus,
                  dadosLuc: dadosLuc,
                  dias: dias,
                ),

              const SizedBox(height: 16),

              // ── Ver/Ocultar detalhes ─────────────────────────────────────
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
                          _tabelaVisivel
                              ? 'Ocultar detalhes'
                              : 'Ver detalhes',
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

              // ── Tabela ───────────────────────────────────────────────────
              if (_tabelaVisivel) ...[
                const SizedBox(height: 16),

                // Sub-abas
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

                // Filtros
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  color: const Color(0xFFE9E4DF),
                  child: Column(
                    children: [
                      // Busca + filtro valor
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
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
                          ),
                          const SizedBox(width: 8),
                          // Botão filtro valor
                          GestureDetector(
                            onTap: _abrirFiltroValor,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: temFiltroValor
                                    ? const Color(0xFFC2463C)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.filter_list,
                                size: 20,
                                color: temFiltroValor
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Filtro categoria
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
                                    borderRadius:
                                        BorderRadius.circular(20),
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

                // Total
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

                // Tabela
                if (isVendas)
                  AdminTabelaVendas(
                    vendas: _paginar(vendasFiltradas),
                    cardapio: _cardapio,
                    fmt: fmt,
                    fmtData: fmtData,
                    onEditar: (vendaAtualizada) async {
                      await _vendaRepo.atualizarVenda(vendaAtualizada);
                      await _carregarDados();
                    },
                    onDeletar: (id) async {
                      await _vendaRepo.deletarVenda(id);
                      await _carregarDados();
                    },
                  )
                else
                  AdminTabelaDespesas(
                    despesas: _paginar(despesasFiltradas),
                    fmt: fmt,
                    fmtData: fmtData,
                    onEditar: (despesaAtualizada) async {
                      await _despesaRepo.atualizarDespesa(despesaAtualizada);
                      await _carregarDados();
                    },
                    onDeletar: (id) async {
                      await _despesaRepo.deletarDespesa(id);
                      await _carregarDados();
                    },
                  ),

                // Paginação
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
                              icon: const Icon(Icons.arrow_back_ios,
                                  size: 16),
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
                              icon: const Icon(Icons.arrow_forward_ios,
                                  size: 16),
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

                // Botões ações
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
                          onPressed: () {
                            // TODO: modal adicionar
                          },
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
                          onPressed: () {
                            // TODO: exportar CSV
                          },
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
}