import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:intl/intl.dart';

enum _ColunaDespesa { data, descricao, categoria, valor }

class AdminTabelaDespesas extends StatefulWidget {
  final List<Despesa> despesas;
  final NumberFormat fmt;
  final DateFormat fmtData;
  final Future<void> Function(Despesa despesaAtualizada) onEditar;
  final Future<void> Function(String id) onDeletar;

  const AdminTabelaDespesas({
    super.key,
    required this.despesas,
    required this.fmt,
    required this.fmtData,
    required this.onEditar,
    required this.onDeletar,
  });

  @override
  State<AdminTabelaDespesas> createState() => _AdminTabelaDespesasState();
}

class _AdminTabelaDespesasState extends State<AdminTabelaDespesas> {
  _ColunaDespesa _colunaOrdenada = _ColunaDespesa.data;
  bool _ascendente = false;
  String? _expandidoId;

  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacaoController = TextEditingController();
  DateTime? _dataEditando;
  String _tipoEditando = 'outros';

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
    _valorController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  List<Despesa> get _despesasOrdenadas {
    final lista = [...widget.despesas];
    lista.sort((a, b) {
      int cmp;
      switch (_colunaOrdenada) {
        case _ColunaDespesa.data:
          cmp = a.data.compareTo(b.data); break;
        case _ColunaDespesa.descricao:
          cmp = a.descricao.compareTo(b.descricao); break;
        case _ColunaDespesa.categoria:
          cmp = a.categoria.compareTo(b.categoria); break;
        case _ColunaDespesa.valor:
          cmp = a.valor.compareTo(b.valor); break;
      }
      return _ascendente ? cmp : -cmp;
    });
    return lista;
  }

  void _ordenarPor(_ColunaDespesa coluna) {
    setState(() {
      if (_colunaOrdenada == coluna) {
        _ascendente = !_ascendente;
      } else {
        _colunaOrdenada = coluna;
        _ascendente = false;
      }
    });
  }

  void _expandir(Despesa despesa) {
    setState(() {
      if (_expandidoId == despesa.id) {
        _expandidoId = null;
      } else {
        _expandidoId = despesa.id;
        _descricaoController.text = despesa.descricao;
        _categoriaController.text = despesa.categoria;
        _valorController.text = despesa.valor.toStringAsFixed(2);
        _observacaoController.text = despesa.observacao ?? '';
        _dataEditando = despesa.data;
        _tipoEditando = despesa.tipo;
      }
    });
  }

  Future<void> _salvar(Despesa original) async {
    final valor = double.tryParse(
        _valorController.text.trim().replaceAll(',', '.'));
    if (valor == null) return;

    await widget.onEditar(Despesa(
      id: original.id,
      descricao: _descricaoController.text.trim(),
      categoria: _categoriaController.text.trim(),
      valor: valor,
      data: _dataEditando ?? original.data,
      observacao: _observacaoController.text.trim().isEmpty
          ? null : _observacaoController.text.trim(),
      tipo: _tipoEditando,
    ));
    setState(() => _expandidoId = null);
  }

  Future<void> _selecionarData(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataEditando ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFC2463C), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dataEditando = picked);
  }

  void _abrirBottomSheet(BuildContext context, Despesa despesa) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DespesaBottomSheet(
        despesa: despesa,
        fmt: widget.fmt,
        fmtData: widget.fmtData,
        onDeletar: () async {
          Navigator.pop(context);
          await widget.onDeletar(despesa.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final despesas = _despesasOrdenadas;

    if (despesas.isEmpty) {
      return const Center(
        child: Text('Nenhuma despesa encontrada',
            style: TextStyle(color: Colors.black38)));
    }

    return Column(
      children: [
        // ── Cabeçalho ──────────────────────────────────────────────────────
        Container(
          color: const Color(0xFFF0F0F0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              _Cabecalho(texto: 'Data', largura: 58,
                  coluna: _ColunaDespesa.data, ativa: _colunaOrdenada,
                  ascendente: _ascendente, onTap: _ordenarPor),
              _Cabecalho(texto: 'Descrição', largura: null,
                  coluna: _ColunaDespesa.descricao, ativa: _colunaOrdenada,
                  ascendente: _ascendente, onTap: _ordenarPor),
              _Cabecalho(texto: 'Valor', largura: 72,
                  coluna: _ColunaDespesa.valor, ativa: _colunaOrdenada,
                  ascendente: _ascendente, onTap: _ordenarPor),
              const SizedBox(width: 20),
            ],
          ),
        ),

        // ── Linhas ─────────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            itemCount: despesas.length,
            itemBuilder: (context, index) {
              final despesa = despesas[index];
              final expandido = _expandidoId == despesa.id;
              final par = index % 2 == 0;

              return Column(
                children: [
                  // Linha compacta
                  GestureDetector(
                    onTap: () => _expandir(despesa),
                    child: Container(
                      decoration: BoxDecoration(
                        color: expandido
                            ? const Color(0xFFFFF0F0)
                            : par
                                ? Colors.white
                                : const Color(0xFFFAFAFA),
                        border: Border(
                          left: expandido
                              ? const BorderSide(
                                  color: Color(0xFFC2463C), width: 3)
                              : BorderSide.none,
                          bottom: BorderSide(
                              color: Colors.grey.shade200, width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 58,
                            child: Text(
                              widget.fmtData.format(despesa.data),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black45),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  despesa.descricao,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  despesa.categoria,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black38),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 72,
                            child: Text(
                              widget.fmt.format(despesa.valor),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC2463C),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            expandido
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expansão inline editável
                  if (expandido)
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0F0),
                        border: Border(
                          left: BorderSide(
                              color: Color(0xFFC2463C), width: 3),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Data
                          GestureDetector(
                            onTap: () => _selecionarData(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 12,
                                      color: Color(0xFFC2463C)),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.fmtData.format(
                                        _dataEditando ?? despesa.data),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          _Campo(
                            label: 'Descrição',
                            controller: _descricaoController,
                          ),
                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Expanded(
                                child: _Campo(
                                  label: 'Categoria',
                                  controller: _categoriaController,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _Campo(
                                  label: 'Valor',
                                  controller: _valorController,
                                  teclado: const TextInputType
                                      .numberWithOptions(decimal: true),
                                  prefixo: 'R\$ ',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Tipo
                          const Text('Tipo',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.black45)),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: _tipos.entries.map((entry) {
                              final sel = entry.key == _tipoEditando;
                              return GestureDetector(
                                onTap: () => setState(
                                    () => _tipoEditando = entry.key),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? const Color(0xFFC2463C)
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    border: Border.all(
                                      color: sel
                                          ? const Color(0xFFC2463C)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(entry.value,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: sel
                                            ? Colors.white
                                            : Colors.black54,
                                      )),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 6),

                          _Campo(
                            label: 'Observação (opcional)',
                            controller: _observacaoController,
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    _abrirBottomSheet(context, despesa),
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero),
                                child: const Text('Ver mais',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45)),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => setState(
                                        () => _expandidoId = null),
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero),
                                    child: const Text('Cancelar',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45)),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 30,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFC2463C),
                                        padding: const EdgeInsets
                                            .symmetric(horizontal: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: () => _salvar(despesa),
                                      child: const Text('Salvar',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Bottom Sheet ──────────────────────────────────────────────────────────────

class _DespesaBottomSheet extends StatelessWidget {
  final Despesa despesa;
  final NumberFormat fmt;
  final DateFormat fmtData;
  final VoidCallback onDeletar;

  const _DespesaBottomSheet({
    required this.despesa,
    required this.fmt,
    required this.fmtData,
    required this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
    final tiposNomes = {
      'ingredientes': 'Ingredientes',
      'mao_de_obra': 'Mão de obra',
      'fixo': 'Custo fixo',
      'operacional': 'Operacional',
      'outros': 'Outros',
    };

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(despesa.descricao,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text(despesa.categoria,
              style: const TextStyle(fontSize: 13, color: Colors.black38)),
          const SizedBox(height: 20),
          _LinhaDetalhe(label: 'Data', valor: fmtData.format(despesa.data)),
          _LinhaDetalhe(label: 'Valor', valor: fmt.format(despesa.valor)),
          _LinhaDetalhe(label: 'Tipo',
              valor: tiposNomes[despesa.tipo] ?? despesa.tipo),
          if (despesa.observacao != null && despesa.observacao!.isNotEmpty)
            _LinhaDetalhe(label: 'Observação', valor: despesa.observacao!),
          _LinhaDetalhe(label: 'ID', valor: despesa.id),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC2463C),
                side: const BorderSide(color: Color(0xFFC2463C)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _confirmarDelecao(context),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Deletar despesa'),
            ),
          ),
          const SizedBox(height: 8),
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
                style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: onDeletar,
            child: const Text('Deletar',
                style: TextStyle(color: Color(0xFFC2463C))),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _LinhaDetalhe extends StatelessWidget {
  final String label;
  final String valor;
  const _LinhaDetalhe({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black45)),
          Flexible(
            child: Text(valor,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final String texto;
  final double? largura;
  final _ColunaDespesa coluna;
  final _ColunaDespesa ativa;
  final bool ascendente;
  final void Function(_ColunaDespesa) onTap;

  const _Cabecalho({
    required this.texto,
    required this.largura,
    required this.coluna,
    required this.ativa,
    required this.ascendente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAtiva = ativa == coluna;
    final child = GestureDetector(
      onTap: () => onTap(coluna),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(texto,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isAtiva
                    ? const Color(0xFFC2463C) : Colors.black45,
              )),
          if (isAtiva) ...[
            const SizedBox(width: 2),
            Icon(
              ascendente ? Icons.arrow_upward : Icons.arrow_downward,
              size: 9,
              color: const Color(0xFFC2463C),
            ),
          ],
        ],
      ),
    );
    if (largura != null) return SizedBox(width: largura, child: child);
    return Expanded(child: child);
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? teclado;
  final String? prefixo;

  const _Campo({
    required this.label,
    required this.controller,
    this.teclado,
    this.prefixo,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixo,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 11, color: Colors.black45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFC2463C)),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 6),
      ),
    );
  }
}