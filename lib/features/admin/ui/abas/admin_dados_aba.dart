import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proj_nape/features/admin/ui/abas/widgets/admin_tabela_despesas.dart';
import 'package:proj_nape/features/admin/ui/abas/widgets/admin_tabela_vendas.dart';
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
  bool _resumoVisivel = false;

  _Periodo _periodoSelecionado = _Periodo.mes;
  DateTimeRange? _periodoCustom;
  String _busca = '';
  String _categoriaSelecionada = 'Todas';
  double? _valorMin;
  double? _valorMax;
  int _paginaAtual = 0;
  int _itensPorPagina = 20;

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
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...opcoes.map((p) => ListTile(
              dense: true,
              leading: Icon(Icons.check,
                color: _periodoSelecionado == p
                    ? const Color(0xFFC2463C) : Colors.transparent,
                size: 16),
              title: Text(p.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _periodoSelecionado == p
                      ? FontWeight.w600 : FontWeight.normal,
                  color: _periodoSelecionado == p
                      ? const Color(0xFFC2463C) : Colors.black87,
                )),
              onTap: () => Navigator.pop(context, p),
            )),
            ListTile(
              dense: true,
              leading: Icon(
                _periodoSelecionado == _Periodo.custom
                    ? Icons.check : Icons.calendar_month_outlined,
                color: _periodoSelecionado == _Periodo.custom
                    ? const Color(0xFFC2463C) : Colors.black54,
                size: 16),
              title: Text('Personalizado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _periodoSelecionado == _Periodo.custom
                      ? FontWeight.w600 : FontWeight.normal,
                  color: _periodoSelecionado == _Periodo.custom
                      ? const Color(0xFFC2463C) : Colors.black87,
                )),
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
      final valorMinOk = _valorMin == null || v.valorTotal >= _valorMin!;
      final valorMaxOk = _valorMax == null || v.valorTotal <= _valorMax!;
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

  void _abrirFiltroValor() {
    final minController = TextEditingController(
        text: _valorMin?.toStringAsFixed(0) ?? '');
    final maxController = TextEditingController(
        text: _valorMax?.toStringAsFixed(0) ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtrar por valor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Mínimo', prefixText: 'R\$ ',
                      filled: true, fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFC2463C)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: maxController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Máximo', prefixText: 'R\$ ',
                      filled: true, fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFC2463C)),
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
                      setState(() { _valorMin = null; _valorMax = null; });
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black54,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _valorMin = double.tryParse(minController.text.replaceAll(',', '.'));
                        _valorMax = double.tryParse(maxController.text.replaceAll(',', '.'));
                        _paginaAtual = 0;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2463C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
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
    if (_carregando) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFC2463C)));
    }

    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final fmtData = DateFormat('dd/MM/yy', 'pt_BR');
    final isVendas = _tabController.index == 0;
    final vendasFiltradas = _vendasFiltradas;
    final despesasFiltradas = _despesasFiltradas;
    final listaFiltrada = isVendas ? vendasFiltradas : despesasFiltradas;
    final temFiltroValor = _valorMin != null || _valorMax != null;

    final totalVendas = vendasFiltradas.fold(0.0, (s, v) => s + v.valorTotal);
    final totalDespesas = despesasFiltradas.fold(0.0, (s, d) => s + d.valor);
    final ticketMedio = vendasFiltradas.isNotEmpty
        ? totalVendas / vendasFiltradas.length : 0.0;
    final mediaDespesa = despesasFiltradas.isNotEmpty
        ? totalDespesas / despesasFiltradas.length : 0.0;
    final cmvTotal = despesasFiltradas
        .where((d) => d.tipo == 'ingredientes')
        .fold(0.0, (s, d) => s + d.valor);
    final cmvPerc = totalVendas > 0 ? (cmvTotal / totalVendas * 100) : 0.0;
    final totalPaginas = (listaFiltrada.length / _itensPorPagina).ceil();

    return Column(
      children: [

        // ── Barra de controles ─────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: _abrirSeletorPeriodo,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E4DF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          size: 13, color: Color(0xFFC2463C)),
                      const SizedBox(width: 4),
                      Text(_labelPeriodo,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down,
                          size: 14, color: Colors.grey.shade500),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Text('Exibir:',
                  style: TextStyle(fontSize: 11, color: Colors.black45)),
              const SizedBox(width: 6),
              ...[20, 50, 100].map((n) {
                final sel = n == _itensPorPagina;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _itensPorPagina = n;
                      _paginaAtual = 0;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFFC2463C) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: sel
                              ? const Color(0xFFC2463C)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text('$n',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : Colors.black54,
                          )),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // ── Sub-abas ───────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFC2463C),
            labelColor: const Color(0xFFC2463C),
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [Tab(text: 'Vendas'), Tab(text: 'Despesas')],
          ),
        ),

        // ── Resumo colapsável ──────────────────────────────────────────────
        Container(
          color: Colors.white,
          child: Column(
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _resumoVisivel = !_resumoVisivel),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        isVendas
                            ? '${vendasFiltradas.length} registros · ${fmt.format(totalVendas)}'
                            : '${despesasFiltradas.length} registros · ${fmt.format(totalDespesas)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _resumoVisivel
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              ),
              if (_resumoVisivel)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Row(
                    children: isVendas
                        ? [
                            _ChipResumo(
                              label: 'Ticket médio',
                              valor: fmt.format(ticketMedio),
                              cor: const Color(0xFF2D74C4),
                            ),
                            const SizedBox(width: 8),
                            _ChipResumo(
                              label: 'Itens vendidos',
                              valor: '${vendasFiltradas.fold(0, (s, v) => s + v.quantidade)}',
                              cor: const Color(0xFF2D74C4),
                            ),
                          ]
                        : [
                            _ChipResumo(
                              label: 'Média',
                              valor: fmt.format(mediaDespesa),
                              cor: const Color(0xFFC2463C),
                            ),
                            const SizedBox(width: 8),
                            _ChipResumo(
                              label: 'CMV',
                              valor: '${cmvPerc.toStringAsFixed(1)}%',
                              cor: cmvPerc <= 35
                                  ? const Color(0xFF3E8E41)
                                  : const Color(0xFFC2463C),
                            ),
                          ],
                  ),
                ),
            ],
          ),
        ),

        // ── Filtros ────────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: TextField(
                        onChanged: (v) => setState(() {
                          _busca = v;
                          _paginaAtual = 0;
                        }),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          hintStyle: const TextStyle(
                              fontSize: 12, color: Colors.black38),
                          prefixIcon: const Icon(Icons.search,
                              size: 16, color: Colors.black38),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _abrirFiltroValor,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: temFiltroValor
                            ? const Color(0xFFC2463C)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.filter_list,
                          size: 18,
                          color: temFiltroValor
                              ? Colors.white : Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 28,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: (isVendas
                          ? _categoriasVendas
                          : _categoriasDespesas)
                      .map((cat) {
                    final sel = cat == _categoriaSelecionada;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _categoriaSelecionada = cat;
                          _paginaAtual = 0;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFFC2463C) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: sel
                                  ? const Color(0xFFC2463C)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(cat,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: sel
                                    ? Colors.white : Colors.black54,
                              )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // ── Divisor entre filtros e tabela ─────────────────────────────────
        Container(
          height: 2,
          color: const Color(0xFFE0E0E0),
        ),

        // ── Tabela ─────────────────────────────────────────────────────────
        Expanded(
          child: Container(
            color: Colors.white,
            child: isVendas
                ? AdminTabelaVendas(
                    vendas: _paginar(vendasFiltradas),
                    cardapio: _cardapio,
                    fmt: fmt,
                    fmtData: fmtData,
                    onEditar: (v) async {
                      await _vendaRepo.atualizarVenda(v);
                      await _carregarDados();
                    },
                    onDeletar: (id) async {
                      await _vendaRepo.deletarVenda(id);
                      await _carregarDados();
                    },
                  )
                : AdminTabelaDespesas(
                    despesas: _paginar(despesasFiltradas),
                    fmt: fmt,
                    fmtData: fmtData,
                    onEditar: (d) async {
                      await _despesaRepo.atualizarDespesa(d);
                      await _carregarDados();
                    },
                    onDeletar: (id) async {
                      await _despesaRepo.deletarDespesa(id);
                      await _carregarDados();
                    },
                  ),
          ),
        ),

        // ── Paginação ──────────────────────────────────────────────────────
        if (totalPaginas > 1)
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_paginaAtual * _itensPorPagina + 1}–'
                  '${((_paginaAtual + 1) * _itensPorPagina).clamp(0, listaFiltrada.length)} '
                  'de ${listaFiltrada.length}',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black54),
                ),
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
                      icon: const Icon(Icons.arrow_back_ios, size: 14),
                      onPressed: _paginaAtual > 0
                          ? () => setState(() => _paginaAtual--)
                          : null,
                      color: const Color(0xFFC2463C),
                    ),
                    Text('${_paginaAtual + 1}/$totalPaginas',
                        style: const TextStyle(fontSize: 12)),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      onPressed: _paginaAtual < totalPaginas - 1
                          ? () => setState(() => _paginaAtual++)
                          : null,
                      color: const Color(0xFFC2463C),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ChipResumo extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;

  const _ChipResumo({
    required this.label,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cor.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Colors.black45)),
            const Spacer(),
            Text(valor,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: cor,
                )),
          ],
        ),
      ),
    );
  }
}