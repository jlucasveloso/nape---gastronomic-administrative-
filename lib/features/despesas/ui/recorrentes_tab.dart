import 'package:flutter/material.dart';

import '../models/despesa_recorrente.dart';

class RecorrentesTab extends StatefulWidget {
  const RecorrentesTab({super.key});

  @override
  State<RecorrentesTab> createState() =>
      _RecorrentesTabState();
}

class _RecorrentesTabState
    extends State<RecorrentesTab> {
  final List<DespesaRecorrente> despesas = [];

  final List<String> sugestoes = [
    'Energia',
    'Água',
    'Aluguel',
    'Internet',
    'Sistema',
    'Contador',
    'Gás',
  ];

  final nomeController = TextEditingController();
  final valorIdealController =
      TextEditingController();
  final valorPagoController =
      TextEditingController();
  final vencimentoController =
      TextEditingController();
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
    valorIdealController.clear();
    valorPagoController.clear();
    vencimentoController.clear();
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
                  'Nova recorrente',
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
                  controller: valorIdealController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor ideal',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: valorPagoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor pago',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: vencimentoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Dia vencimento',
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
                      'Salvar recorrente',
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

    final despesa = DespesaRecorrente(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      nome: nome,
      categoria: nome,
      valorIdeal:
          converterValor(valorIdealController.text),
      valorPago:
          converterValor(valorPagoController.text),
      diaVencimento:
          int.tryParse(vencimentoController.text) ??
              1,
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
    valorIdealController.dispose();
    valorPagoController.dispose();
    vencimentoController.dispose();
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
            'Recorrentes cadastradas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          if (despesas.isEmpty)
            const Text(
              'Nenhuma recorrente cadastrada.',
            ),

          ...despesas.map((despesa) {
            final diferenca =
                despesa.valorPago -
                    despesa.valorIdeal;

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
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        despesa.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'Dia ${despesa.diaVencimento}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Ideal: R\$ ${despesa.valorIdeal.toStringAsFixed(2)}',
                  ),

                  Text(
                    'Pago: R\$ ${despesa.valorPago.toStringAsFixed(2)}',
                  ),

                  const SizedBox(height: 8),

                  Text(
                    diferenca > 0
                        ? '+R\$ ${diferenca.toStringAsFixed(2)} acima do esperado'
                        : diferenca < 0
                            ? '-R\$ ${diferenca.abs().toStringAsFixed(2)} abaixo do esperado'
                            : 'Dentro do esperado',
                    style: TextStyle(
                      color: diferenca > 0
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
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