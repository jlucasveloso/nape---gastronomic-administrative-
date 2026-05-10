import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:intl/intl.dart';

enum _Coluna { data, descricao, categoria, valor }

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
  _Coluna _colunaOrdenada = _Coluna.data;
  bool _ascendente = false;
  String? _editandoId;

  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime? _dataEditando;

  @override
  void dispose() {
    _descricaoController.dispose();
    _categoriaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  List<Despesa> get _despesasOrdenadas {
    final lista = [...widget.despesas];
    lista.sort((a, b) {
      int cmp;
      switch (_colunaOrdenada) {
        case _Coluna.data:
          cmp = a.data.compareTo(b.data);
          break;
        case _Coluna.descricao:
          cmp = a.descricao.compareTo(b.descricao);
          break;
        case _Coluna.categoria:
          cmp = a.categoria.compareTo(b.categoria);
          break;
        case _Coluna.valor:
          cmp = a.valor.compareTo(b.valor);
          break;
      }
      return _ascendente ? cmp : -cmp;
    });
    return lista;
  }

  void _iniciarEdicao(Despesa despesa) {
    setState(() {
      _editandoId = despesa.id;
      _descricaoController.text = despesa.descricao;
      _categoriaController.text = despesa.categoria;
      _valorController.text = despesa.valor.toStringAsFixed(2);
      _dataEditando = despesa.data;
    });
  }

  void _cancelarEdicao() {
    setState(() => _editandoId = null);
  }

  Future<void> _salvarEdicao(Despesa despesaOriginal) async {
    final valor = double.tryParse(
        _valorController.text.trim().replaceAll(',', '.'));
    if (valor == null) return;

    final despesaAtualizada = Despesa(
      id: despesaOriginal.id,
      descricao: _descricaoController.text.trim(),
      categoria: _categoriaController.text.trim(),
      valor: valor,
      data: _dataEditando ?? despesaOriginal.data,
    );

    await widget.onEditar(despesaAtualizada);
    setState(() => _editandoId = null);
  }

  void _ordenarPor(_Coluna coluna) {
    setState(() {
      if (_colunaOrdenada == coluna) {
        _ascendente = !_ascendente;
      } else {
        _colunaOrdenada = coluna;
        _ascendente = false;
      }
    });
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
            primary: Color(0xFFC2463C),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dataEditando = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = widget.fmt;
    final fmtData = widget.fmtData;
    final despesas = _despesasOrdenadas;

    return Column(
      children: [
        // ── Cabeçalho ────────────────────────────────────────────────────
        Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _Cabecalho(
                texto: 'Data',
                largura: 70,
                coluna: _Coluna.data,
                ativa: _colunaOrdenada,
                ascendente: _ascendente,
                onTap: _ordenarPor,
              ),
              const SizedBox(width: 4),
              _Cabecalho(
                texto: 'Descrição',
                largura: null,
                coluna: _Coluna.descricao,
                ativa: _colunaOrdenada,
                ascendente: _ascendente,
                onTap: _ordenarPor,
              ),
              const SizedBox(width: 4),
              _Cabecalho(
                texto: 'Categ.',
                largura: 70,
                coluna: _Coluna.categoria,
                ativa: _colunaOrdenada,
                ascendente: _ascendente,
                onTap: _ordenarPor,
              ),
              const SizedBox(width: 4),
              _Cabecalho(
                texto: 'Valor',
                largura: 70,
                coluna: _Coluna.valor,
                ativa: _colunaOrdenada,
                ascendente: _ascendente,
                onTap: _ordenarPor,
              ),
              const SizedBox(width: 32),
            ],
          ),
        ),

        // ── Linhas ───────────────────────────────────────────────────────
        if (despesas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Nenhuma despesa encontrada',
                style: TextStyle(color: Colors.black38),
              ),
            ),
          )
        else
          ...despesas.map((despesa) {
            final estaEditando = _editandoId == despesa.id;

            if (estaEditando) {
              return _LinhaEdicaoDespesa(
                despesa: despesa,
                descricaoController: _descricaoController,
                categoriaController: _categoriaController,
                valorController: _valorController,
                dataEditando: _dataEditando ?? despesa.data,
                fmtData: fmtData,
                onSelecionarData: () => _selecionarData(context),
                onSalvar: () => _salvarEdicao(despesa),
                onCancelar: _cancelarEdicao,
              );
            }

            return _LinhaDespesa(
              despesa: despesa,
              fmt: fmt,
              fmtData: fmtData,
              onEditar: () => _iniciarEdicao(despesa),
              onDeletar: () => _confirmarDelecao(context, despesa),
            );
          }),
      ],
    );
  }

  void _confirmarDelecao(BuildContext context, Despesa despesa) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            onPressed: () {
              Navigator.pop(context);
              widget.onDeletar(despesa.id);
            },
            child: const Text('Deletar',
                style: TextStyle(color: Color(0xFFC2463C))),
          ),
        ],
      ),
    );
  }
}

// ── Cabeçalho clicável ────────────────────────────────────────────────────────

class _Cabecalho extends StatelessWidget {
  final String texto;
  final double? largura;
  final _Coluna coluna;
  final _Coluna ativa;
  final bool ascendente;
  final void Function(_Coluna) onTap;

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
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isAtiva ? const Color(0xFFC2463C) : Colors.black45,
            ),
          ),
          if (isAtiva) ...[
            const SizedBox(width: 2),
            Icon(
              ascendente ? Icons.arrow_upward : Icons.arrow_downward,
              size: 10,
              color: const Color(0xFFC2463C),
            ),
          ],
        ],
      ),
    );

    if (largura != null) {
      return SizedBox(width: largura, child: child);
    }
    return Expanded(child: child);
  }
}

// ── Linha normal ──────────────────────────────────────────────────────────────

class _LinhaDespesa extends StatelessWidget {
  final Despesa despesa;
  final NumberFormat fmt;
  final DateFormat fmtData;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;

  const _LinhaDespesa({
    required this.despesa,
    required this.fmt,
    required this.fmtData,
    required this.onEditar,
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
            width: 70,
            child: Text(fmtData.format(despesa.data),
                style:
                    const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  despesa.descricao,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  despesa.categoria,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
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
            icon: const Icon(Icons.more_vert,
                size: 18, color: Colors.black38),
            onSelected: (value) {
              if (value == 'editar') onEditar();
              if (value == 'deletar') onDeletar();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(children: [
                  Icon(Icons.edit_outlined,
                      size: 16, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Editar', style: TextStyle(fontSize: 13)),
                ]),
              ),
              const PopupMenuItem(
                value: 'deletar',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      size: 16, color: Color(0xFFC2463C)),
                  SizedBox(width: 8),
                  Text('Deletar',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFFC2463C))),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Linha em edição ───────────────────────────────────────────────────────────

class _LinhaEdicaoDespesa extends StatelessWidget {
  final Despesa despesa;
  final TextEditingController descricaoController;
  final TextEditingController categoriaController;
  final TextEditingController valorController;
  final DateTime dataEditando;
  final DateFormat fmtData;
  final VoidCallback onSelecionarData;
  final VoidCallback onSalvar;
  final VoidCallback onCancelar;

  const _LinhaEdicaoDespesa({
    required this.despesa,
    required this.descricaoController,
    required this.categoriaController,
    required this.valorController,
    required this.dataEditando,
    required this.fmtData,
    required this.onSelecionarData,
    required this.onSalvar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
          left: const BorderSide(color: Color(0xFFC2463C), width: 3),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data
          GestureDetector(
            onTap: onSelecionarData,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Color(0xFFC2463C)),
                  const SizedBox(width: 6),
                  Text(
                    fmtData.format(dataEditando),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Descrição
          _Campo(
            label: 'Descrição',
            controller: descricaoController,
          ),
          const SizedBox(height: 8),

          // Categoria e Valor
          Row(
            children: [
              Expanded(
                child: _Campo(
                  label: 'Categoria',
                  controller: categoriaController,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Campo(
                  label: 'Valor',
                  controller: valorController,
                  teclado: const TextInputType.numberWithOptions(
                      decimal: true),
                  prefixo: 'R\$ ',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Botões
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancelar,
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2463C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onSalvar,
                child: const Text('Salvar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Campo ─────────────────────────────────────────────────────────────────────

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
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixo,
        filled: true,
        fillColor: Colors.white,
        labelStyle:
            const TextStyle(fontSize: 12, color: Colors.black45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC2463C)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}