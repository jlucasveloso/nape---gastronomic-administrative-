import 'package:flutter/material.dart';

import '../models/despesa_normal.dart';

class NormaisTab extends StatefulWidget {
  const NormaisTab({super.key});

  @override
  State<NormaisTab> createState() =>
      _NormaisTabState();
}

class _NormaisTabState extends State<NormaisTab> {
  final List<DespesaNormal> despesas = [];

  final List<String> sugestoes = [
    'Feira',
    'Limpeza',
    'Utensílios',
    'Manutenção',
    'Embalagens',
    'Emergencial',
  ];

  final nomeController = TextEditingController();
  final valorController = TextEditingController();
  final observacaoController =
      TextEditingController();

  double converterValor(String valor) {
    return double.tryParse(
          valor.replaceAll(',', '.'),
        ) ??
        0;
  }

  void limparCampos() {
    nomeController.clear();
    valorController.clear();
    observacaoController.clear();
  }

  void abrirModalAdicionar({
    String? nomeInicial,
  }) {
    limparCampos();

    if (nomeInicial != null) {
      nomeController.text = nomeInicial;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFE9E4DF),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                    16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nova despesa',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: observacaoController,
                  decoration: const InputDecoration(
                    labelText: 'Observação',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFC2463C),
                    ),
                    onPressed: salvarDespesa,
                    child: const Text(
                      'Salvar despesa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void salvarDespesa() {
    final nome = nomeController.text.trim();

    if (nome.isEmpty) {
      return;
    }

    final despesa = DespesaNormal(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      nome: nome,
      categoria: nome,
      valor:
          converterValor(valorController.text),
      data: DateTime.now(),
      observacao:
          observacaoController.text.trim(),
    );

    setState(() {
      despesas.add(despesa);
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nomeController.dispose();
    valorController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E4DF),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Sugestões rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: sugestoes.map((sugestao) {
              return GestureDetector(
                onTap: () => abrirModalAdicionar(
                  nomeInicial: sugestao,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: Text(
                    sugestao,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          const Text(
            'Despesas cadastradas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          if (despesas.isEmpty)
            const Text(
              'Nenhuma despesa cadastrada.',
            ),

          ...despesas.map((despesa) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        despesa.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        despesa.categoria,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    'R\$ ${despesa.valor.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFC2463C),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC2463C),
        onPressed: abrirModalAdicionar,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Adicionar',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}