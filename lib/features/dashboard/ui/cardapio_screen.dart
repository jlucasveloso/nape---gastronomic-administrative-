import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj_nape/app_state.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:intl/intl.dart';

class CardapioScreen extends StatelessWidget {
  const CardapioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E4DF),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFC2463C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const Text(
              'Cardápio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ── Conteúdo ──────────────────────────────────────────────────────
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, _) {
                if (appState.carregando) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC2463C),
                    ),
                  );
                }

                final produtos = appState.cardapio;

                if (produtos.isEmpty) {
                  return _EstadoVazio();
                }

                // Agrupar por categoria
                final Map<String, List<ProdutoCardapio>> porCategoria = {};
                for (final p in produtos) {
                  porCategoria.putIfAbsent(p.categoria, () => []).add(p);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  itemCount: porCategoria.length,
                  itemBuilder: (context, index) {
                    final categoria = porCategoria.keys.elementAt(index);
                    final itensDaCategoria = porCategoria[categoria]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label da categoria
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC2463C),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                categoria,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Produtos da categoria
                        ...itensDaCategoria.map((produto) =>
                            _ProdutoCard(produto: produto)),

                        const SizedBox(height: 24),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ── Botão flutuante ───────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC2463C),
        onPressed: () => _abrirModalProduto(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _abrirModalProduto(BuildContext context, {ProdutoCardapio? produto}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ModalProduto(produto: produto),
    );
  }
}

// ── Estado vazio ──────────────────────────────────────────────────────────────

class _EstadoVazio extends StatelessWidget {
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
            child: const Icon(
              Icons.restaurant_menu_outlined,
              size: 36,
              color: Color(0xFFC2463C),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Seu cardápio está vazio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione seu primeiro produto',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card de produto ───────────────────────────────────────────────────────────

class _ProdutoCard extends StatelessWidget {
  final ProdutoCardapio produto;

  const _ProdutoCard({required this.produto});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          produto.nome,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          produto.categoria,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black38,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              fmt.format(produto.preco),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E8E41),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  size: 20, color: Colors.black38),
              onSelected: (value) {
                if (value == 'editar') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) => _ModalProduto(produto: produto),
                  );
                } else if (value == 'deletar') {
                  _confirmarDelecao(context);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 18, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'deletar',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: Color(0xFFC2463C)),
                      SizedBox(width: 8),
                      Text('Remover',
                          style: TextStyle(color: Color(0xFFC2463C))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarDelecao(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Remover produto'),
        content: Text(
          'Deseja remover "${produto.nome}" do cardápio?\nAs vendas registradas não serão afetadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppState>().deletarProduto(produto.id);
            },
            child: const Text('Remover',
                style: TextStyle(color: Color(0xFFC2463C))),
          ),
        ],
      ),
    );
  }
}

// ── Modal de adicionar/editar produto ─────────────────────────────────────────

class _ModalProduto extends StatefulWidget {
  final ProdutoCardapio? produto;

  const _ModalProduto({this.produto});

  @override
  State<_ModalProduto> createState() => _ModalProdutoState();
}

class _ModalProdutoState extends State<_ModalProduto> {
  late final TextEditingController _nomeController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _precoController;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nomeController =
        TextEditingController(text: widget.produto?.nome ?? '');
    _categoriaController =
        TextEditingController(text: widget.produto?.categoria ?? '');
    _precoController = TextEditingController(
      text: widget.produto != null
          ? widget.produto!.preco.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    final categoria = _categoriaController.text.trim();
    final precoText = _precoController.text.trim().replaceAll(',', '.');
    final preco = double.tryParse(precoText);

    if (nome.isEmpty || categoria.isEmpty || preco == null) return;

    setState(() => _salvando = true);

    try {
      final appState = context.read<AppState>();

      if (widget.produto == null) {
        // Adicionar novo produto
        await appState.adicionarProduto(
          ProdutoCardapio(
            id: '',
            nome: nome,
            categoria: categoria,
            preco: preco,
            dataCadastro: DateTime.now(),
          ),
        );
      } else {
        // Editar produto existente
        await appState.editarProduto(
          ProdutoCardapio(
            id: widget.produto!.id,
            nome: nome,
            categoria: categoria,
            preco: preco,
            dataCadastro: widget.produto!.dataCadastro,
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao salvar produto: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.produto != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alça
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              isEdicao ? 'Editar produto' : 'Novo produto',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            _campo('Nome do produto', _nomeController),
            const SizedBox(height: 12),
            _campo('Categoria', _categoriaController,
                hint: 'Ex: Bebidas, Lanches...'),
            const SizedBox(height: 12),
            _campo('Preço', _precoController,
                hint: '0,00',
                teclado: TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2463C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEdicao ? 'Salvar alterações' : 'Adicionar produto',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController controller,
      {String? hint, TextInputType? teclado}) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      decoration: InputDecoration(
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
      ),
    );
  }
}