import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj_nape/app_state.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:intl/intl.dart';
import 'package:proj_nape/main_screen.dart';

class FaturamentoScreen extends StatefulWidget {
  const FaturamentoScreen({super.key});

  @override
  State<FaturamentoScreen> createState() => _FaturamentoScreenState();
}

class _FaturamentoScreenState extends State<FaturamentoScreen> {
  String _categoriaSelecionada = 'Todas';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final fmtData = DateFormat('dd/MM/yyyy HH:mm');

    // Filtrar por categoria
    final vendas = _categoriaSelecionada == 'Todas'
        ? appState.vendas
        : appState.vendas
            .where((v) => v.categoriaSnapshot == _categoriaSelecionada)
            .toList();

    // Total faturado
    final total = vendas.fold(0.0, (s, v) => s + v.valorTotal);

    // Categorias disponíveis
    final categorias = ['Todas', ...appState.vendas
        .map((v) => v.categoriaSnapshot)
        .toSet()
        .toList()];

    return Scaffold(
      backgroundColor: const Color(0xFFE9E4DF),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF2D74C4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botão voltar
                GestureDetector(
  onTap: () => mainScreenKey.currentState?.trocarAba(0),
  child: const Icon(Icons.arrow_back_ios,
      color: Colors.white, size: 20),
),
                const SizedBox(height: 12),
                const Text(
                  'Vendas',
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
              ],
            ),
          ),

          // ── Conteúdo ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // ── Botão análise + filtro categoria ──────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      // Botão análise
                      GestureDetector(
                        onTap: () {
                          // TODO: navegar para Análise filtrada em Vendas
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D74C4).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF2D74C4).withOpacity(0.2)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart,
                                  size: 18, color: Color(0xFF2D74C4)),
                              SizedBox(width: 8),
                              Text(
                                'Análise de vendas',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D74C4),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios,
                                  size: 12, color: Color(0xFF2D74C4)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filtro por categoria
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categorias.map((cat) {
                            final selecionado = cat == _categoriaSelecionada;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _categoriaSelecionada = cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selecionado
                                        ? const Color(0xFF2D74C4)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selecionado
                                          ? const Color(0xFF2D74C4)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: selecionado
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

                const SizedBox(height: 16),

                // ── Lista de vendas ────────────────────────────────────────
                Expanded(
                  child: vendas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D74C4)
                                      .withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 36,
                                  color: Color(0xFF2D74C4),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nenhuma venda registrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Toque em + para registrar uma venda',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: vendas.length,
                          itemBuilder: (context, index) {
                            final venda = vendas[index];
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
                                  // Ícone
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D74C4)
                                          .withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 20,
                                      color: Color(0xFF2D74C4),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Informações
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          venda.nomeProdutoSnapshot,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${venda.categoriaSnapshot} · ${venda.quantidade}x · ${fmtData.format(venda.data)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Valor
                                  Text(
                                    fmt.format(venda.valorTotal),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D74C4),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── Botão flutuante ───────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D74C4),
        onPressed: () => _abrirModalVenda(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _abrirModalVenda(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ModalVenda(),
    );
  }
}

// ── Modal de adicionar venda ──────────────────────────────────────────────────

class _ModalVenda extends StatefulWidget {
  const _ModalVenda();

  @override
  State<_ModalVenda> createState() => _ModalVendaState();
}

class _ModalVendaState extends State<_ModalVenda> {
  final _buscaController = TextEditingController();
  ProdutoCardapio? _produtoSelecionado;
  int _quantidade = 1;
  bool _salvando = false;
  String _termoBusca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_produtoSelecionado == null) return;

    setState(() => _salvando = true);

    try {
      final venda = Venda(
        id: '',
        produtoId: _produtoSelecionado!.id,
        nomeProdutoSnapshot: _produtoSelecionado!.nome,
        categoriaSnapshot: _produtoSelecionado!.categoria,
        precoUnitarioSnapshot: _produtoSelecionado!.preco,
        quantidade: _quantidade,
        data: DateTime.now(),
      );

      await context.read<AppState>().adicionarVenda(venda);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao salvar venda: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Filtrar produtos pelo termo de busca
    final produtosFiltrados = appState.cardapio
        .where((p) =>
            p.nome.toLowerCase().contains(_termoBusca.toLowerCase()) ||
            p.categoria.toLowerCase().contains(_termoBusca.toLowerCase()))
        .toList();

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

            const Text(
              'Nova venda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Campo de busca
            TextField(
              controller: _buscaController,
              onChanged: (v) => setState(() => _termoBusca = v),
              decoration: InputDecoration(
                hintText: 'Pesquisar produto...',
                prefixIcon: const Icon(Icons.search,
                    color: Colors.black38, size: 20),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF2D74C4), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Produto selecionado
            if (_produtoSelecionado != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D74C4).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF2D74C4).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF2D74C4), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _produtoSelecionado!.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D74C4),
                        ),
                      ),
                    ),
                    Text(
                      fmt.format(_produtoSelecionado!.preco),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D74C4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Seletor de quantidade
              Row(
                children: [
                  const Text(
                    'Quantidade:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (_quantidade > 1) {
                        setState(() => _quantidade--);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.remove, size: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_quantidade',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _quantidade++),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D74C4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    fmt.format(
                        _produtoSelecionado!.preco * _quantidade),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E8E41),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botão salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D74C4),
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
                      : const Text(
                          'Registrar venda',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ]

            // Lista de produtos para seleção
            else if (produtosFiltrados.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Nenhum produto encontrado',
                    style: TextStyle(color: Colors.black38),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: produtosFiltrados.length,
                  itemBuilder: (context, index) {
                    final produto = produtosFiltrados[index];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        produto.nome,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        produto.categoria,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        fmt.format(produto.preco),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E8E41),
                        ),
                      ),
                      onTap: () => setState(() {
                        _produtoSelecionado = produto;
                        _buscaController.clear();
                        _termoBusca = '';
                      }),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}