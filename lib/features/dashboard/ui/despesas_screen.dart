import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj_nape/app_state.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/main_screen.dart';
import 'package:intl/intl.dart';

class DespesasScreen extends StatefulWidget {
  const DespesasScreen({super.key});

  @override
  State<DespesasScreen> createState() => _DespesasScreenState();
}

class _DespesasScreenState extends State<DespesasScreen> {
  String _categoriaSelecionada = 'Todas';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final fmtData = DateFormat('dd/MM/yyyy HH:mm');

    // Filtrar por categoria
    final despesas = _categoriaSelecionada == 'Todas'
        ? appState.despesas
        : appState.despesas
            .where((d) => d.categoria == _categoriaSelecionada)
            .toList();

    // Total de despesas
    final total = despesas.fold(0.0, (s, d) => s + d.valor);

    // Categorias disponíveis
    final categorias = ['Todas', ...appState.despesas
        .map((d) => d.categoria)
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
              ],
            ),
          ),

          // ── Conteúdo ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      // Botão análise
                      GestureDetector(
                        onTap: () {
                          // TODO: navegar para Análise filtrada em Despesas
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC2463C).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    const Color(0xFFC2463C).withOpacity(0.2)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart,
                                  size: 18, color: Color(0xFFC2463C)),
                              SizedBox(width: 8),
                              Text(
                                'Análise de despesas',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFC2463C),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios,
                                  size: 12, color: Color(0xFFC2463C)),
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
                                        ? const Color(0xFFC2463C)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selecionado
                                          ? const Color(0xFFC2463C)
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

                // ── Lista de despesas ──────────────────────────────────────
                Expanded(
                  child: despesas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC2463C)
                                      .withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_outlined,
                                  size: 36,
                                  color: Color(0xFFC2463C),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Nenhuma despesa registrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Toque em + para registrar uma despesa',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: despesas.length,
                          itemBuilder: (context, index) {
                            final despesa = despesas[index];
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
                                      color: const Color(0xFFC2463C)
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.money_off_outlined,
                                      size: 20,
                                      color: Color(0xFFC2463C),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          despesa.descricao,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${despesa.categoria} · ${fmtData.format(despesa.data)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    fmt.format(despesa.valor),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFC2463C),
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
        backgroundColor: const Color(0xFFC2463C),
        onPressed: () => _abrirModalDespesa(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _abrirModalDespesa(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ModalDespesa(
        categoriasExistentes: context
            .read<AppState>()
            .despesas
            .map((d) => d.categoria)
            .toSet()
            .toList(),
      ),
    );
  }
}

// ── Modal de adicionar despesa ────────────────────────────────────────────────

class _ModalDespesa extends StatefulWidget {
  final List<String> categoriasExistentes;

  const _ModalDespesa({required this.categoriasExistentes});

  @override
  State<_ModalDespesa> createState() => _ModalDespesaState();
}

class _ModalDespesaState extends State<_ModalDespesa> {
  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _valorController = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    _categoriaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final descricao = _descricaoController.text.trim();
    final categoria = _categoriaController.text.trim();
    final valorText = _valorController.text.trim().replaceAll(',', '.');
    final valor = double.tryParse(valorText);

    if (descricao.isEmpty || categoria.isEmpty || valor == null) return;

    setState(() => _salvando = true);

    try {
      await context.read<AppState>().adicionarDespesa(
            Despesa(
              id: '',
              descricao: descricao,
              categoria: categoria,
              valor: valor,
              data: DateTime.now(),
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
              'Nova despesa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            _campo('Descrição', _descricaoController,
                hint: 'Ex: Compra de carne'),
            const SizedBox(height: 12),

            // Campo categoria com sugestões
            Autocomplete<String>(
              optionsBuilder: (value) {
                if (value.text.isEmpty) return widget.categoriasExistentes;
                return widget.categoriasExistentes.where((cat) => cat
                    .toLowerCase()
                    .contains(value.text.toLowerCase()));
              },
              onSelected: (value) =>
                  _categoriaController.text = value,
              fieldViewBuilder:
                  (context, controller, focusNode, onSubmitted) {
                _categoriaController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (v) => _categoriaController.text = v,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    hintText: 'Ex: Ingredientes, Funcionários...',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    labelStyle: const TextStyle(
                        fontSize: 13, color: Colors.black45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFC2463C), width: 1.5),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _campo('Valor', _valorController,
                hint: '0,00',
                teclado:
                    TextInputType.numberWithOptions(decimal: true)),
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
                    : const Text(
                        'Registrar despesa',
                        style: TextStyle(
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
        labelStyle:
            const TextStyle(fontSize: 13, color: Colors.black45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFC2463C), width: 1.5),
        ),
      ),
    );
  }
}