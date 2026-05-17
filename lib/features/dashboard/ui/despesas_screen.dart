import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj_nape/app_state.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/features/dashboard/model/despesa_recorrente.dart';
import 'package:proj_nape/features/dashboard/model/registro_recorrente.dart';
import 'package:proj_nape/features/dashboard/model/funcionario.dart';
import 'package:proj_nape/features/dashboard/model/pagamento_funcionario.dart';
import 'package:proj_nape/main_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:proj_nape/shared/widgets/campo_monetario.dart';

class DespesasScreen extends StatefulWidget {
  const DespesasScreen({super.key});

  @override
  State<DespesasScreen> createState() => _DespesasScreenState();
}

class _DespesasScreenState extends State<DespesasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _competenciaAtual() {
    final agora = DateTime.now();
    return '${agora.year}-${agora.month.toString().padLeft(2, '0')}';
  }

  double _totalAba(AppState appState) {
    final fmt = _competenciaAtual();
    switch (_tabController.index) {
      case 0:
        return appState.despesas.fold(0.0, (s, d) => s + d.valor);
      case 1:
        return appState.registrosRecorrentes
            .where((r) => r.competencia == fmt)
            .fold(0.0, (s, r) => s + r.valor);
      case 2:
        return appState.pagamentos
            .where((p) => p.competencia == fmt && p.status != 'cancelado')
            .fold(0.0, (s, p) => s + p.valor);
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final total = _totalAba(appState);

    return Scaffold(
      backgroundColor: const Color(0xFFE9E4DF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
            decoration: const BoxDecoration(
              color: Color(0xFFC2463C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => mainScreenKey.currentState?.trocarAba(0),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Despesas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${fmt.format(total)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  tabs: const [
                    Tab(text: 'Comuns'),
                    Tab(text: 'Recorrentes'),
                    Tab(text: 'Funcionários'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _AbaComuns(),
                _AbaRecorrentes(),
                _AbaFuncionarios(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC2463C),
        onPressed: () => _abrirModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _abrirModal(BuildContext context) {
    switch (_tabController.index) {
      case 0:
        _abrirModalDespesaComum(context);
        break;
      case 1:
        _abrirModalRecorrente(context);
        break;
      case 2:
        _abrirModalFuncionario(context);
        break;
    }
  }

  void _abrirModalDespesaComum(BuildContext context) {
    final appState = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ModalDespesaComum(
        categoriasExistentes: appState.despesas
            .map((d) => d.categoria)
            .toSet()
            .toList(),
      ),
    );
  }

  void _abrirModalRecorrente(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ModalRecorrente(),
    );
  }

  void _abrirModalFuncionario(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ModalFuncionario(),
    );
  }
}

// ── ABA COMUNS ────────────────────────────────────────────────────────────────

class _AbaComuns extends StatefulWidget {
  const _AbaComuns();

  @override
  State<_AbaComuns> createState() => _AbaComunsState();
}

class _AbaComunsState extends State<_AbaComuns> {
  String _categoriaSelecionada = 'Todas';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final fmtData = DateFormat('dd/MM/yyyy HH:mm');

    final despesas = _categoriaSelecionada == 'Todas'
        ? appState.despesas
        : appState.despesas
            .where((d) => d.categoria == _categoriaSelecionada)
            .toList();

    final categorias = [
      'Todas',
      ...appState.despesas.map((d) => d.categoria).toSet().toList()
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categorias.map((cat) {
                final sel = cat == _categoriaSelecionada;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _categoriaSelecionada = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFFC2463C) : Colors.white,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: sel ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: despesas.isEmpty
              ? _EstadoVazio(
                  icone: Icons.receipt_outlined,
                  mensagem: 'Nenhuma despesa registrada',
                  dica: 'Toque em + para registrar uma despesa',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: despesas.length,
                  itemBuilder: (context, index) {
                    final despesa = despesas[index];
                    return _CardDespesa(
                      despesa: despesa,
                      fmt: fmt,
                      fmtData: fmtData,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── ABA RECORRENTES ───────────────────────────────────────────────────────────

class _AbaRecorrentes extends StatelessWidget {
  const _AbaRecorrentes();

  String _competenciaAtual() {
    final agora = DateTime.now();
    return '${agora.year}-${agora.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final competencia = _competenciaAtual();

    final pagoIds = appState.registrosRecorrentes
        .where((r) => r.competencia == competencia)
        .map((r) => r.despesaRecorrenteId)
        .toSet();

    final recorrentes = appState.recorrentes;

    if (recorrentes.isEmpty) {
      return _EstadoVazio(
        icone: Icons.repeat_outlined,
        mensagem: 'Nenhuma despesa recorrente',
        dica: 'Toque em + para adicionar uma despesa recorrente',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: recorrentes.length,
      itemBuilder: (context, index) {
        final recorrente = recorrentes[index];
        final pago = pagoIds.contains(recorrente.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: pago
                      ? const Color(0xFF3E8E41).withOpacity(0.1)
                      : const Color(0xFFC2463C).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  pago ? Icons.check_circle_outline : Icons.pending_outlined,
                  size: 20,
                  color: pago
                      ? const Color(0xFF3E8E41)
                      : const Color(0xFFC2463C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recorrente.descricao,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vence dia ${recorrente.diaVencimento} · ${fmt.format(recorrente.valorReferencia)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              if (!pago)
                GestureDetector(
                  onTap: () => _registrarPagamento(context, recorrente, fmt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2463C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pagar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                const Text(
                  'Pago',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3E8E41),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _registrarPagamento(
    BuildContext context,
    DespesaRecorrente recorrente,
    NumberFormat fmt,
  ) {
    final agora = DateTime.now();
    final competencia =
        '${agora.year}-${agora.month.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ModalRegistrarRecorrente(
        recorrente: recorrente,
        competencia: competencia,
        fmt: fmt,
      ),
    );
  }
}

// ── ABA FUNCIONÁRIOS ──────────────────────────────────────────────────────────

class _AbaFuncionarios extends StatelessWidget {
  const _AbaFuncionarios();

  String _competenciaAtual() {
    final agora = DateTime.now();
    return '${agora.year}-${agora.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final competencia = _competenciaAtual();

    final funcionarios = appState.funcionarios
        .where((f) => f.status == 'ativo')
        .toList();

    if (funcionarios.isEmpty) {
      return _EstadoVazio(
        icone: Icons.people_outline,
        mensagem: 'Nenhum funcionário cadastrado',
        dica: 'Toque em + para adicionar um funcionário',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: funcionarios.length,
      itemBuilder: (context, index) {
        final funcionario = funcionarios[index];
        final pagamentosMes = appState.pagamentos
            .where((p) =>
                p.funcionarioId == funcionario.id &&
                p.competencia == competencia &&
                p.status != 'cancelado')
            .toList();
        final totalPago = pagamentosMes.fold(0.0, (s, p) => s + p.valor);
        final temPendente = pagamentosMes.any((p) => p.status == 'pendente');

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D74C4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 20,
                  color: Color(0xFF2D74C4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      funcionario.nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${funcionario.cargo} · ${fmt.format(funcionario.salarioBase)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
                      ),
                    ),
                    if (totalPago > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Pago este mês: ${fmt.format(totalPago)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3E8E41),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (temPendente)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC2463C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pendente',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFC2463C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 18, color: Colors.black38),
                onSelected: (value) {
                  if (value == 'pagamento') {
                    _abrirModalPagamento(context, funcionario, fmt);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'pagamento',
                    child: Row(children: [
                      Icon(Icons.payment_outlined,
                          size: 16, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('Registrar pagamento',
                          style: TextStyle(fontSize: 13)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _abrirModalPagamento(
    BuildContext context,
    Funcionario funcionario,
    NumberFormat fmt,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ModalPagamentoFuncionario(
        funcionario: funcionario,
        fmt: fmt,
      ),
    );
  }
}

// ── MODAIS ────────────────────────────────────────────────────────────────────

class _ModalDespesaComum extends StatefulWidget {
  final List<String> categoriasExistentes;
  const _ModalDespesaComum({required this.categoriasExistentes});

  @override
  State<_ModalDespesaComum> createState() => _ModalDespesaComumState();
}

class _ModalDespesaComumState extends State<_ModalDespesaComum> {
  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();
  String _tipoSelecionado = 'outros';
  double _valor = 0.0;
  bool _salvando = false;

  final _tipos = {
    'ingredientes': 'Ingredientes',
    'mao_de_obra': 'Mão de obra',
    'fixo': 'Custo fixo',
    'operacional': 'Operacional',
    'outros': 'Outros',
  };

  @override
  void dispose() {
    _descricaoController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final descricao = _descricaoController.text.trim();
    final categoria = _categoriaController.text.trim();

    if (descricao.isEmpty || categoria.isEmpty || _valor <= 0) return;

    setState(() => _salvando = true);
    try {
      await context.read<AppState>().adicionarDespesa(
            Despesa(
              id: '',
              descricao: descricao,
              categoria: categoria,
              valor: _valor,
              data: DateTime.now(),
              tipo: _tipoSelecionado,
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao salvar despesa: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _alca(),
            const SizedBox(height: 20),
            const Text('Nova despesa',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 20),
            _campo('Descrição', _descricaoController,
                hint: 'Ex: Compra de carne'),
            const SizedBox(height: 12),
            Autocomplete<String>(
              optionsBuilder: (value) {
                if (value.text.isEmpty) return widget.categoriasExistentes;
                return widget.categoriasExistentes.where((cat) =>
                    cat.toLowerCase().contains(value.text.toLowerCase()));
              },
              onSelected: (value) => _categoriaController.text = value,
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                _categoriaController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (v) => _categoriaController.text = v,
                  decoration: _inputDecoration('Categoria',
                      hint: 'Ex: Ingredientes, Funcionários...'),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Tipo',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Define como essa despesa aparece na Análise',
              style: TextStyle(fontSize: 11, color: Colors.black38),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tipos.entries.map((entry) {
                final sel = entry.key == _tipoSelecionado;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _tipoSelecionado = entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFFC2463C) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel
                            ? const Color(0xFFC2463C)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: sel ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            CampoMonetario(
              label: 'Valor',
              onChanged: (v) => _valor = v,
            ),
            const SizedBox(height: 24),
            _botaoSalvar(_salvando, _salvar, 'Registrar despesa'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ModalRecorrente extends StatefulWidget {
  const _ModalRecorrente();

  @override
  State<_ModalRecorrente> createState() => _ModalRecorrenteState();
}

class _ModalRecorrenteState extends State<_ModalRecorrente> {
  final _descricaoController = TextEditingController();
  final _diaController = TextEditingController();
  double _valor = 0.0;
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _descricaoController.dispose();
    _diaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final descricao = _descricaoController.text.trim();
    final dia = int.tryParse(_diaController.text.trim());

    if (descricao.isEmpty) {
      setState(() => _erro = 'Informe a descrição');
      return;
    }
    if (_valor <= 0) {
      setState(() => _erro = 'Informe um valor válido');
      return;
    }
    if (dia == null || dia < 1 || dia > 31) {
      setState(() => _erro = 'Dia de vencimento deve ser entre 1 e 31');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      await context.read<AppState>().adicionarRecorrente(
            DespesaRecorrente(
              id: '',
              userId: '',
              descricao: descricao,
              valorReferencia: _valor,
              diaVencimento: dia,
              createdAt: DateTime.now(),
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _erro = 'Erro ao salvar. Tente novamente.');
      debugPrint('Erro ao salvar recorrente: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _alca(),
            const SizedBox(height: 20),
            const Text('Nova despesa recorrente',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 6),
            const Text(
              'O valor padrão será sugerido todo mês ao registrar o pagamento.',
              style: TextStyle(fontSize: 12, color: Colors.black38),
            ),
            const SizedBox(height: 20),
            _campo('Descrição', _descricaoController, hint: 'Ex: Aluguel'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CampoMonetario(
                    label: 'Valor padrão',
                    onChanged: (v) => _valor = v,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _diaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: _inputDecoration('Dia venc.', hint: '1–31'),
                  ),
                ),
              ],
            ),
            if (_erro != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 14, color: Color(0xFFC2463C)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _erro!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFC2463C)),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            _botaoSalvar(_salvando, _salvar, 'Adicionar recorrente'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ModalRegistrarRecorrente extends StatefulWidget {
  final DespesaRecorrente recorrente;
  final String competencia;
  final NumberFormat fmt;

  const _ModalRegistrarRecorrente({
    required this.recorrente,
    required this.competencia,
    required this.fmt,
  });

  @override
  State<_ModalRegistrarRecorrente> createState() =>
      _ModalRegistrarRecorrenteState();
}

class _ModalRegistrarRecorrenteState
    extends State<_ModalRegistrarRecorrente> {
  late double _valor;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _valor = widget.recorrente.valorReferencia;
  }

  Future<void> _salvar() async {
    if (_valor <= 0) return;

    setState(() => _salvando = true);
    try {
      await context.read<AppState>().registrarPagamentoRecorrente(
            RegistroRecorrente(
              id: '',
              despesaRecorrenteId: widget.recorrente.id,
              userId: '',
              valor: _valor,
              competencia: widget.competencia,
              registradoEm: DateTime.now(),
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao registrar pagamento: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _alca(),
            const SizedBox(height: 20),
            Text(
              'Pagar — ${widget.recorrente.descricao}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            CampoMonetario(
              label: 'Valor pago',
              valorInicial: widget.recorrente.valorReferencia,
              onChanged: (v) => _valor = v,
            ),
            const SizedBox(height: 24),
            _botaoSalvar(_salvando, _salvar, 'Confirmar pagamento'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ModalFuncionario extends StatefulWidget {
  const _ModalFuncionario();

  @override
  State<_ModalFuncionario> createState() => _ModalFuncionarioState();
}

class _ModalFuncionarioState extends State<_ModalFuncionario> {
  final _nomeController = TextEditingController();
  final _cargoController = TextEditingController();
  double _salario = 0.0;
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    final cargo = _cargoController.text.trim();

    if (nome.isEmpty || cargo.isEmpty || _salario <= 0) return;

    setState(() => _salvando = true);
    try {
      await context.read<AppState>().adicionarFuncionario(
            Funcionario(
              id: '',
              userId: '',
              nome: nome,
              cargo: cargo,
              salarioBase: _salario,
              dataAdmissao: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao salvar funcionário: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _alca(),
            const SizedBox(height: 20),
            const Text('Novo funcionário',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 20),
            _campo('Nome', _nomeController, hint: 'Ex: João Silva'),
            const SizedBox(height: 12),
            _campo('Cargo', _cargoController, hint: 'Ex: Cozinheiro'),
            const SizedBox(height: 12),
            CampoMonetario(
              label: 'Salário base',
              onChanged: (v) => _salario = v,
            ),
            const SizedBox(height: 24),
            _botaoSalvar(_salvando, _salvar, 'Adicionar funcionário'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ModalPagamentoFuncionario extends StatefulWidget {
  final Funcionario funcionario;
  final NumberFormat fmt;

  const _ModalPagamentoFuncionario({
    required this.funcionario,
    required this.fmt,
  });

  @override
  State<_ModalPagamentoFuncionario> createState() =>
      _ModalPagamentoFuncionarioState();
}

class _ModalPagamentoFuncionarioState
    extends State<_ModalPagamentoFuncionario> {
  late double _valor;
  String _tipoSelecionado = 'salario';
  bool _salvando = false;

  final _tipos = {
    'salario': 'Salário',
    'comissao': 'Comissão',
    'bonus': 'Bônus',
    'diaria': 'Diária',
    'desconto': 'Desconto',
    'ferias': 'Férias',
    'decimo': '13º salário',
    'rescisao': 'Rescisão',
  };

  @override
  void initState() {
    super.initState();
    _valor = widget.funcionario.salarioBase;
  }

  String _competenciaAtual() {
    final agora = DateTime.now();
    return '${agora.year}-${agora.month.toString().padLeft(2, '0')}';
  }

  Future<void> _salvar() async {
    if (_valor <= 0) return;

    setState(() => _salvando = true);
    try {
      await context.read<AppState>().adicionarPagamentoFuncionario(
            PagamentoFuncionario(
              id: '',
              funcionarioId: widget.funcionario.id,
              userId: '',
              tipo: _tipoSelecionado,
              valor: _valor,
              competencia: _competenciaAtual(),
              status: 'pago',
              dataPagamento: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao registrar pagamento: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _alca(),
            const SizedBox(height: 20),
            Text(
              'Pagamento — ${widget.funcionario.nome}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const Text('Tipo',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tipos.entries.map((entry) {
                  final sel = entry.key == _tipoSelecionado;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _tipoSelecionado = entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFFC2463C) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel
                                ? const Color(0xFFC2463C)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: sel ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            CampoMonetario(
              label: 'Valor',
              valorInicial: widget.funcionario.salarioBase,
              onChanged: (v) => _valor = v,
            ),
            const SizedBox(height: 24),
            _botaoSalvar(_salvando, _salvar, 'Confirmar pagamento'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── WIDGETS COMPARTILHADOS ────────────────────────────────────────────────────

class _CardDespesa extends StatelessWidget {
  final Despesa despesa;
  final NumberFormat fmt;
  final DateFormat fmtData;

  const _CardDespesa({
    required this.despesa,
    required this.fmt,
    required this.fmtData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFC2463C).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.money_off_outlined,
                size: 20, color: Color(0xFFC2463C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(despesa.descricao,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(
                  '${despesa.categoria} · ${fmtData.format(despesa.data)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ],
            ),
          ),
          Text(
            fmt.format(despesa.valor),
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC2463C)),
          ),
        ],
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String mensagem;
  final String dica;

  const _EstadoVazio({
    required this.icone,
    required this.mensagem,
    required this.dica,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFC2463C).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 36, color: const Color(0xFFC2463C)),
          ),
          const SizedBox(height: 16),
          Text(mensagem,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54)),
          const SizedBox(height: 8),
          Text(dica,
              style: const TextStyle(fontSize: 13, color: Colors.black38)),
        ],
      ),
    );
  }
}

// ── HELPERS ───────────────────────────────────────────────────────────────────

Widget _alca() {
  return Center(
    child: Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

Widget _campo(
  String label,
  TextEditingController controller, {
  String? hint,
  TextInputType? teclado,
}) {
  return TextField(
    controller: controller,
    keyboardType: teclado,
    decoration: _inputDecoration(label, hint: hint),
  );
}

InputDecoration _inputDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    labelStyle: const TextStyle(fontSize: 13, color: Colors.black45),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFC2463C), width: 1.5),
    ),
  );
}

Widget _botaoSalvar(bool salvando, VoidCallback onPressed, String label) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC2463C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: salvando ? null : onPressed,
      child: salvando
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
    ),
  );
}