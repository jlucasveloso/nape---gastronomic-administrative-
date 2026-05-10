import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/controller/dashboard_controller.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';
import 'package:proj_nape/repositories/despesa_repository.dart';
import 'package:proj_nape/repositories/venda_repository.dart';
import 'package:proj_nape/shared/widgets/info_card.dart';
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

class AdminResumoAba extends StatefulWidget {
  final String userId;

  const AdminResumoAba({super.key, required this.userId});

  @override
  State<AdminResumoAba> createState() => _AdminResumoAbaState();
}

class _AdminResumoAbaState extends State<AdminResumoAba> {
  final _vendaRepo = VendaRepository();
  final _despesaRepo = DespesaRepository();

  List<Venda> _vendas = [];
  List<Despesa> _despesas = [];
  bool _carregando = true;

  _Periodo _periodoSelecionado = _Periodo.mes;
  DateTimeRange? _periodoCustom;

  @override
  void initState() {
    super.initState();
    _carregarDados();
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
      debugPrint('Erro ao carregar dados: $e');
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

  String get _labelAtivo {
    if (_periodoSelecionado == _Periodo.custom && _periodoCustom != null) {
      final fmt = DateFormat('d MMM', 'pt_BR');
      return '${fmt.format(_periodoCustom!.start)} a ${fmt.format(_periodoCustom!.end)}';
    }
    return _periodoSelecionado.label;
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

  void _abrirSeletor() async {
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
                    ? _labelAtivo
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

  @override
  Widget build(BuildContext context) {
    final intervalo = _intervalo;
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

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

    final bool emPrejuizo = controller.lucro < 0;
    final Color corLucro =
        emPrejuizo ? const Color(0xFFC2463C) : const Color(0xFF3E8E41);
    final String tituloLucro = emPrejuizo ? 'Prejuízo' : 'Lucro';
    final IconData iconeLucro = emPrejuizo
        ? Icons.trending_down
        : Icons.account_balance_wallet_outlined;
    final String subtituloLucro = emPrejuizo
        ? '↓ ${controller.margemLucroPercent.abs().toStringAsFixed(0)}% de margem'
        : '${controller.margemLucroPercent.toStringAsFixed(0)}% de margem';

    return _carregando
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFC2463C)))
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Seletor de período ───────────────────────────────────────
              GestureDetector(
                onTap: _abrirSeletor,
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

              const Text(
                'Resumo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 16),

              // ── Cards ────────────────────────────────────────────────────
              InfoCard(
                titulo: 'Faturamento',
                valor: fmt.format(controller.faturamentoTotal),
                subtitulo: '${vendasFiltradas.fold(0, (s, v) => s + v.quantidade)} itens vendidos',
                cor: const Color(0xFF2D74C4),
                icone: Icons.trending_up,
              ),
              const SizedBox(height: 12),
              InfoCard(
                titulo: 'Custos',
                valor: fmt.format(controller.custosTotal),
                subtitulo: '${controller.custosPorCategoria.keys.length} categorias',
                cor: const Color(0xFFC2463C),
                icone: Icons.trending_down,
              ),
              const SizedBox(height: 12),
              InfoCard(
                titulo: tituloLucro,
                valor: fmt.format(controller.lucro.abs()),
                subtitulo: subtituloLucro,
                cor: corLucro,
                icone: iconeLucro,
              ),
            ],
          );
  }
}