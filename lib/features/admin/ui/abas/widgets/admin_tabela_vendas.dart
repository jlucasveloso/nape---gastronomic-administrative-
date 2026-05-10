import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';
import 'package:intl/intl.dart';

enum _Coluna { data, produto, categoria, quantidade, total }

class AdminTabelaVendas extends StatefulWidget {
  final List<Venda> vendas;
  final List<ProdutoCardapio> cardapio;
  final NumberFormat fmt;
  final DateFormat fmtData;
  final Future<void> Function(Venda vendaAtualizada) onEditar;
  final Future<void> Function(String id) onDeletar;

  const AdminTabelaVendas({
    super.key,
    required this.vendas,
    required this.cardapio,
    required this.fmt,
    required this.fmtData,
    required this.onEditar,
    required this.onDeletar,
  });

  @override
  State<AdminTabelaVendas> createState() => _AdminTabelaVendasState();
}

class _AdminTabelaVendasState extends State<AdminTabelaVendas> {
  _Coluna _colunaOrdenada = _Coluna.data;
  bool _ascendente = false;
  String? _editandoId;

  // Controllers para edição inline
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  DateTime? _dataEditando;
  ProdutoCardapio? _produtoSelecionado;
  bool _mostrandoBuscaProduto = false;
  String _termoBusca = '';

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  List<Venda> get _vendasOrdenadas {
    final lista = [...widget.vendas];
    lista.sort((a, b) {
      int cmp;
      switch (_colunaOrdenada) {
        case _Coluna.data:
          cmp = a.data.compareTo(b.data);
          break;
        case _Coluna.produto:
          cmp = a.nomeProdutoSnapshot.compareTo(b.nomeProdutoSnapshot);
          break;
        case _Coluna.categoria:
          cmp = a.categoriaSnapshot.compareTo(b.categoriaSnapshot);
          break;
        case _Coluna.quantidade:
          cmp = a.quantidade.compareTo(b.quantidade);
          break;
        case _Coluna.total:
          cmp = a.valorTotal.compareTo(b.valorTotal);
          break;
      }
      return _ascendente ? cmp : -cmp;
    });
    return lista;
  }

  void _iniciarEdicao(Venda venda) {
    setState(() {
      _editandoId = venda.id;
      _nomeController.text = venda.nomeProdutoSnapshot;
      _categoriaController.text = venda.categoriaSnapshot;
      _precoController.text = venda.precoUnitarioSnapshot.toStringAsFixed(2);
      _quantidadeController.text = venda.quantidade.toString();
      _dataEditando = venda.data;
      _produtoSelecionado = null;
      _mostrandoBuscaProduto = false;
      _termoBusca = '';
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _editandoId = null;
      _mostrandoBuscaProduto = false;
      _termoBusca = '';
    });
  }

  Future<void> _salvarEdicao(Venda vendaOriginal) async {
    final preco = double.tryParse(
        _precoController.text.trim().replaceAll(',', '.'));
    final quantidade = int.tryParse(_quantidadeController.text.trim());

    if (preco == null || quantidade == null) return;

    final vendaAtualizada = Venda(
      id: vendaOriginal.id,
      produtoId: _produtoSelecionado?.id ?? vendaOriginal.produtoId,
      nomeProdutoSnapshot: _nomeController.text.trim(),
      categoriaSnapshot: _categoriaController.text.trim(),
      precoUnitarioSnapshot: preco,
      quantidade: quantidade,
      data: _dataEditando ?? vendaOriginal.data,
    );

    await widget.onEditar(vendaAtualizada);
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
    final vendas = _vendasOrdenadas;

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
                texto: 'Produto',
                largura: null,
                coluna: _Coluna.produto,
                ativa: _colunaOrdenada,
                ascendente: _ascendente,
                onTap: _ordenarPor,
              ),
              const SizedBox(width: 4),
              _Cabecalho(
                texto: 'Qtd',
                largura: 35,
                coluna: _Coluna.quantidade,
                ativa: _colunaOrdenada,
                ascendente: _ascendente,
                onTap: _ordenarPor,
              ),
              const SizedBox(width: 4),
              _Cabecalho(
                texto: 'Total',
                largura: 70,
                coluna: _Coluna.total,
                ativa: _colunaOrdenada,
                ascendente: _ascendente,
                onTap: _ordenarPor,
              ),
              const SizedBox(width: 32),
            ],
          ),
        ),

        // ── Linhas ───────────────────────────────────────────────────────
        if (vendas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Nenhuma venda encontrada',
                style: TextStyle(color: Colors.black38),
              ),
            ),
          )
        else
          ...vendas.map((venda) {
            final estaEditando = _editandoId == venda.id;

            if (estaEditando) {
              return _LinhaEdicaoVenda(
                venda: venda,
                cardapio: widget.cardapio,
                nomeController: _nomeController,
                categoriaController: _categoriaController,
                precoController: _precoController,
                quantidadeController: _quantidadeController,
                dataEditando: _dataEditando ?? venda.data,
                produtoSelecionado: _produtoSelecionado,
                mostrandoBusca: _mostrandoBuscaProduto,
                termoBusca: _termoBusca,
                fmt: fmt,
                fmtData: fmtData,
                onSelecionarData: () => _selecionarData(context),
                onToggleBusca: () => setState(() {
                  _mostrandoBuscaProduto = !_mostrandoBuscaProduto;
                  _termoBusca = '';
                }),
                onBuscaChanged: (v) => setState(() => _termoBusca = v),
                onSelecionarProduto: (p) => setState(() {
                  _produtoSelecionado = p;
                  _nomeController.text = p.nome;
                  _categoriaController.text = p.categoria;
                  _precoController.text = p.preco.toStringAsFixed(2);
                  _mostrandoBuscaProduto = false;
                  _termoBusca = '';
                }),
                onSalvar: () => _salvarEdicao(venda),
                onCancelar: _cancelarEdicao,
              );
            }

            return _LinhaVenda(
              venda: venda,
              fmt: fmt,
              fmtData: fmtData,
              onEditar: () => _iniciarEdicao(venda),
              onDeletar: () => _confirmarDelecao(context, venda),
            );
          }),
      ],
    );
  }

  void _confirmarDelecao(BuildContext context, Venda venda) {
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
                style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeletar(venda.id);
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
    final widget = GestureDetector(
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
      return SizedBox(width: largura, child: widget);
    }
    return Expanded(child: widget);
  }
}

// ── Linha normal ──────────────────────────────────────────────────────────────

class _LinhaVenda extends StatelessWidget {
  final Venda venda;
  final NumberFormat fmt;
  final DateFormat fmtData;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;

  const _LinhaVenda({
    required this.venda,
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
            child: Text(fmtData.format(venda.data),
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venda.nomeProdutoSnapshot,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  venda.categoriaSnapshot,
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 35,
            child: Text('${venda.quantidade}x',
                style:
                    const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
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

class _LinhaEdicaoVenda extends StatelessWidget {
  final Venda venda;
  final List<ProdutoCardapio> cardapio;
  final TextEditingController nomeController;
  final TextEditingController categoriaController;
  final TextEditingController precoController;
  final TextEditingController quantidadeController;
  final DateTime dataEditando;
  final ProdutoCardapio? produtoSelecionado;
  final bool mostrandoBusca;
  final String termoBusca;
  final NumberFormat fmt;
  final DateFormat fmtData;
  final VoidCallback onSelecionarData;
  final VoidCallback onToggleBusca;
  final void Function(String) onBuscaChanged;
  final void Function(ProdutoCardapio) onSelecionarProduto;
  final VoidCallback onSalvar;
  final VoidCallback onCancelar;

  const _LinhaEdicaoVenda({
    required this.venda,
    required this.cardapio,
    required this.nomeController,
    required this.categoriaController,
    required this.precoController,
    required this.quantidadeController,
    required this.dataEditando,
    required this.produtoSelecionado,
    required this.mostrandoBusca,
    required this.termoBusca,
    required this.fmt,
    required this.fmtData,
    required this.onSelecionarData,
    required this.onToggleBusca,
    required this.onBuscaChanged,
    required this.onSelecionarProduto,
    required this.onSalvar,
    required this.onCancelar,
  });

  List<ProdutoCardapio> get _produtosFiltrados => cardapio
      .where((p) =>
          p.nome.toLowerCase().contains(termoBusca.toLowerCase()) ||
          p.categoria.toLowerCase().contains(termoBusca.toLowerCase()))
      .toList();

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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

          // Produto — busca no cardápio
          GestureDetector(
            onTap: onToggleBusca,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: mostrandoBusca
                      ? const Color(0xFFC2463C)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search,
                      size: 16, color: Colors.black38),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      nomeController.text.isEmpty
                          ? 'Selecionar produto...'
                          : nomeController.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: nomeController.text.isEmpty
                            ? Colors.black38
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    mostrandoBusca
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),

          // Lista de produtos
          if (mostrandoBusca) ...[
            const SizedBox(height: 4),
            TextField(
              autofocus: true,
              onChanged: onBuscaChanged,
              decoration: InputDecoration(
                hintText: 'Buscar no cardápio...',
                hintStyle:
                    const TextStyle(fontSize: 12, color: Colors.black38),
                prefixIcon: const Icon(Icons.search,
                    size: 16, color: Colors.black38),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _produtosFiltrados.length,
                itemBuilder: (context, index) {
                  final p = _produtosFiltrados[index];
                  return ListTile(
                    dense: true,
                    title: Text(p.nome,
                        style: const TextStyle(fontSize: 13)),
                    subtitle: Text(p.categoria,
                        style: const TextStyle(fontSize: 11)),
                    trailing: Text(
                      fmt.format(p.preco),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E8E41),
                      ),
                    ),
                    onTap: () => onSelecionarProduto(p),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Quantidade e Preço
          Row(
            children: [
              Expanded(
                child: _Campo(
                  label: 'Quantidade',
                  controller: quantidadeController,
                  teclado: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Campo(
                  label: 'Preço unit.',
                  controller: precoController,
                  teclado: const TextInputType.numberWithOptions(
                      decimal: true),
                  prefixo: 'R\$ ',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Botões confirmar/cancelar
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

// ── Campo de input ────────────────────────────────────────────────────────────

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