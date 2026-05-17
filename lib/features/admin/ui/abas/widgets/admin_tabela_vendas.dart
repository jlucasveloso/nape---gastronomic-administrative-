import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';
import 'package:proj_nape/shared/widgets/campo_monetario.dart';
import 'package:intl/intl.dart';

enum _ColunaVenda { data, produto, quantidade, total }

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
  _ColunaVenda _colunaOrdenada = _ColunaVenda.data;
  bool _ascendente = false;
  String? _expandidoId;

  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _quantidadeController = TextEditingController();
  DateTime? _dataEditando;
  ProdutoCardapio? _produtoSelecionado;
  bool _mostrandoBuscaProduto = false;
  String _termoBusca = '';
  double _precoEditando = 0.0;

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  List<Venda> get _vendasOrdenadas {
    final lista = [...widget.vendas];
    lista.sort((a, b) {
      int cmp;
      switch (_colunaOrdenada) {
        case _ColunaVenda.data:
          cmp = a.data.compareTo(b.data); break;
        case _ColunaVenda.produto:
          cmp = a.nomeProdutoSnapshot.compareTo(b.nomeProdutoSnapshot); break;
        case _ColunaVenda.quantidade:
          cmp = a.quantidade.compareTo(b.quantidade); break;
        case _ColunaVenda.total:
          cmp = a.valorTotal.compareTo(b.valorTotal); break;
      }
      return _ascendente ? cmp : -cmp;
    });
    return lista;
  }

  void _ordenarPor(_ColunaVenda coluna) {
    setState(() {
      if (_colunaOrdenada == coluna) {
        _ascendente = !_ascendente;
      } else {
        _colunaOrdenada = coluna;
        _ascendente = false;
      }
    });
  }

  void _expandir(Venda venda) {
    setState(() {
      if (_expandidoId == venda.id) {
        _expandidoId = null;
      } else {
        _expandidoId = venda.id;
        _nomeController.text = venda.nomeProdutoSnapshot;
        _categoriaController.text = venda.categoriaSnapshot;
        _quantidadeController.text = venda.quantidade.toString();
        _dataEditando = venda.data;
        _produtoSelecionado = null;
        _mostrandoBuscaProduto = false;
        _termoBusca = '';
        _precoEditando = venda.precoUnitarioSnapshot;
      }
    });
  }

  Future<void> _salvar(Venda original) async {
    final quantidade = int.tryParse(_quantidadeController.text.trim());
    if (_precoEditando <= 0 || quantidade == null) return;

    await widget.onEditar(Venda(
      id: original.id,
      produtoId: _produtoSelecionado?.id ?? original.produtoId,
      nomeProdutoSnapshot: _nomeController.text.trim(),
      categoriaSnapshot: _categoriaController.text.trim(),
      precoUnitarioSnapshot: _precoEditando,
      quantidade: quantidade,
      data: _dataEditando ?? original.data,
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

  void _abrirBottomSheet(BuildContext context, Venda venda) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _VendaBottomSheet(
        venda: venda,
        fmt: widget.fmt,
        fmtData: widget.fmtData,
        onDeletar: () async {
          Navigator.pop(context);
          await widget.onDeletar(venda.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendas = _vendasOrdenadas;

    if (vendas.isEmpty) {
      return const Center(
        child: Text('Nenhuma venda encontrada',
            style: TextStyle(color: Colors.black38)));
    }

    return Column(
      children: [
        Container(
          color: const Color(0xFF2D2D2D),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              _Cabecalho(texto: 'Data', largura: 58,
                  coluna: _ColunaVenda.data, ativa: _colunaOrdenada,
                  ascendente: _ascendente, onTap: _ordenarPor),
              _Cabecalho(texto: 'Produto', largura: null,
                  coluna: _ColunaVenda.produto, ativa: _colunaOrdenada,
                  ascendente: _ascendente, onTap: _ordenarPor),
              _Cabecalho(texto: 'Qtd', largura: 30,
                  coluna: _ColunaVenda.quantidade, ativa: _colunaOrdenada,
                  ascendente: _ascendente, onTap: _ordenarPor),
              _Cabecalho(texto: 'Total', largura: 72,
                  coluna: _ColunaVenda.total, ativa: _colunaOrdenada,
                  ascendente: _ascendente, onTap: _ordenarPor),
              const SizedBox(width: 20),
            ],
          ),
        ),

        Expanded(
          child: ColoredBox(
            color: Colors.white,
            child: ListView.builder(
              itemCount: vendas.length,
              itemBuilder: (context, index) {
                final venda = vendas[index];
                final expandido = _expandidoId == venda.id;
                final par = index % 2 == 0;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => _expandir(venda),
                      child: Container(
                        decoration: BoxDecoration(
                          color: expandido
                              ? const Color(0xFFFFF0F0)
                              : par ? Colors.white : const Color(0xFFFAFAFA),
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
                                widget.fmtData.format(venda.data),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black45),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                venda.nomeProdutoSnapshot,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text('${venda.quantidade}x',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black45)),
                            ),
                            SizedBox(
                              width: 72,
                              child: Text(
                                widget.fmt.format(venda.valorTotal),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D74C4),
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
                                          _dataEditando ?? venda.data),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Busca produto
                            GestureDetector(
                              onTap: () => setState(() {
                                _mostrandoBuscaProduto =
                                    !_mostrandoBuscaProduto;
                                _termoBusca = '';
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _mostrandoBuscaProduto
                                        ? const Color(0xFFC2463C)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search,
                                        size: 14, color: Colors.black38),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        _nomeController.text.isEmpty
                                            ? 'Selecionar produto...'
                                            : _nomeController.text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _nomeController.text.isEmpty
                                              ? Colors.black38
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      _mostrandoBuscaProduto
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 14,
                                      color: Colors.black38,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (_mostrandoBuscaProduto) ...[
                              const SizedBox(height: 4),
                              TextField(
                                autofocus: true,
                                onChanged: (v) =>
                                    setState(() => _termoBusca = v),
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'Buscar no cardápio...',
                                  hintStyle: const TextStyle(
                                      fontSize: 12, color: Colors.black38),
                                  prefixIcon: const Icon(Icons.search,
                                      size: 14, color: Colors.black38),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 120),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                ),
                                child: ListView(
                                  shrinkWrap: true,
                                  children: widget.cardapio
                                      .where((p) =>
                                          p.nome.toLowerCase().contains(
                                              _termoBusca.toLowerCase()) ||
                                          p.categoria.toLowerCase().contains(
                                              _termoBusca.toLowerCase()))
                                      .map((p) => ListTile(
                                            dense: true,
                                            title: Text(p.nome,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            subtitle: Text(p.categoria,
                                                style: const TextStyle(
                                                    fontSize: 11)),
                                            trailing: Text(
                                              widget.fmt.format(p.preco),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF3E8E41),
                                              ),
                                            ),
                                            onTap: () => setState(() {
                                              _produtoSelecionado = p;
                                              _nomeController.text = p.nome;
                                              _categoriaController.text =
                                                  p.categoria;
                                              _precoEditando = p.preco;
                                              _mostrandoBuscaProduto = false;
                                              _termoBusca = '';
                                            }),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],

                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _Campo(
                                    label: 'Qtd',
                                    controller: _quantidadeController,
                                    teclado: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CampoMonetario(
                                    label: 'Preço unit.',
                                    valorInicial: venda.precoUnitarioSnapshot,
                                    onChanged: (v) => _precoEditando = v,
                                    decoration: InputDecoration(
                                      labelText: 'Preço unit.',
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelStyle: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black45),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFC2463C)),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      _abrirBottomSheet(context, venda),
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
                                        onPressed: () => _salvar(venda),
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
        ),
      ],
    );
  }
}

// ── Bottom Sheet ──────────────────────────────────────────────────────────────

class _VendaBottomSheet extends StatelessWidget {
  final Venda venda;
  final NumberFormat fmt;
  final DateFormat fmtData;
  final VoidCallback onDeletar;

  const _VendaBottomSheet({
    required this.venda,
    required this.fmt,
    required this.fmtData,
    required this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(venda.nomeProdutoSnapshot,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text(venda.categoriaSnapshot,
              style: const TextStyle(fontSize: 13, color: Colors.black38)),
          const SizedBox(height: 20),
          _LinhaDetalhe(label: 'Data', valor: fmtData.format(venda.data)),
          _LinhaDetalhe(label: 'Quantidade', valor: '${venda.quantidade}x'),
          _LinhaDetalhe(label: 'Preço unit.',
              valor: fmt.format(venda.precoUnitarioSnapshot)),
          _LinhaDetalhe(label: 'Total', valor: fmt.format(venda.valorTotal)),
          _LinhaDetalhe(label: 'ID', valor: venda.id),
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
              label: const Text('Deletar venda'),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
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
  final _ColunaVenda coluna;
  final _ColunaVenda ativa;
  final bool ascendente;
  final void Function(_ColunaVenda) onTap;

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
                    ? const Color(0xFFFFB300) : Colors.white70,
                letterSpacing: 0.5,
              )),
          if (isAtiva) ...[
            const SizedBox(width: 2),
            Icon(
              ascendente ? Icons.arrow_upward : Icons.arrow_downward,
              size: 9,
              color: const Color(0xFFFFB300),
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