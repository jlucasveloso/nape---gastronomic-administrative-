import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:proj_nape/repositories/cardapio_repository.dart';
import 'package:intl/intl.dart';

class AdminCardapioAba extends StatefulWidget {
  final String userId;

  const AdminCardapioAba({super.key, required this.userId});

  @override
  State<AdminCardapioAba> createState() => _AdminCardapioAbaState();
}

class _AdminCardapioAbaState extends State<AdminCardapioAba> {
  final _cardapioRepo = CardapioRepository();
  List<ProdutoCardapio> _produtos = [];
  bool _carregando = true;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() => _carregando = true);
    try {
      final produtos =
          await _cardapioRepo.buscarProdutos(userId: widget.userId);
      setState(() {
        _produtos = produtos;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  List<ProdutoCardapio> get _produtosFiltrados {
    if (_busca.isEmpty) return _produtos;
    return _produtos
        .where((p) =>
            p.nome.toLowerCase().contains(_busca.toLowerCase()) ||
            p.categoria.toLowerCase().contains(_busca.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final fmtData = DateFormat('dd/MM/yy', 'pt_BR');

    return _carregando
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFC2463C)))
        : Column(
            children: [
              // ── Busca ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFE9E4DF),
                child: TextField(
                  onChanged: (v) => setState(() => _busca = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar produto...',
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

              // ── Total ──────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Text(
                  '${_produtosFiltrados.length} produtos',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),

              // ── Cabeçalho ──────────────────────────────────────────────
              Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nome',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        'Categoria',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        'Preço',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    SizedBox(width: 32),
                  ],
                ),
              ),

              // ── Lista ──────────────────────────────────────────────────
              Expanded(
                child: _produtosFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum produto encontrado',
                          style: TextStyle(color: Colors.black38),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _produtosFiltrados.length,
                        itemBuilder: (context, index) {
                          final produto = _produtosFiltrados[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade100),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        produto.nome,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Cadastrado: ${fmtData.format(produto.dataCadastro)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black38,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    produto.categoria,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    fmt.format(produto.preco),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3E8E41),
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert,
                                      size: 18, color: Colors.black38),
                                  onSelected: (value) {
                                    if (value == 'editar') {
                                      // TODO: modal de edição
                                    } else if (value == 'deletar') {
                                      _confirmarDelecao(
                                          context, produto);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'editar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined,
                                              size: 16,
                                              color: Colors.black54),
                                          SizedBox(width: 8),
                                          Text('Editar',
                                              style: TextStyle(
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'deletar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline,
                                              size: 16,
                                              color: Color(0xFFC2463C)),
                                          SizedBox(width: 8),
                                          Text('Deletar',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(
                                                      0xFFC2463C))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // ── Ação adicionar ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC2463C),
                      side:
                          const BorderSide(color: Color(0xFFC2463C)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // TODO: modal de adicionar produto
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar produto'),
                  ),
                ),
              ),
            ],
          );
  }

  void _confirmarDelecao(BuildContext context, ProdutoCardapio produto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Deletar produto'),
        content: Text(
            'Deseja deletar "${produto.nome}" do cardápio?\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cardapioRepo.deletarProduto(produto.id);
              _carregarProdutos();
            },
            child: const Text('Deletar',
                style: TextStyle(color: Color(0xFFC2463C))),
          ),
        ],
      ),
    );
  }
}