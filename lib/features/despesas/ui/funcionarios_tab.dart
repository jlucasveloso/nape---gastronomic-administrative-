import 'package:flutter/material.dart';

import '../models/funcionario_mes.dart';

class FuncionariosTab extends StatefulWidget {
  const FuncionariosTab({super.key});

  @override
  State<FuncionariosTab> createState() => _FuncionariosTabState();
}

class _FuncionariosTabState extends State<FuncionariosTab> {
  final List<FuncionarioMes> funcionarios = [];

  final nomeController = TextEditingController();
  final cargoController = TextEditingController();
  final salarioController = TextEditingController();
  final horaExtraController = TextEditingController();
  final comissaoController = TextEditingController();
  final observacaoController = TextEditingController();

  double converterValor(String valor) {
    return double.tryParse(
          valor.replaceAll(',', '.'),
        ) ??
        0;
  }

  double get totalFolha {
    return funcionarios.fold(
      0,
      (total, funcionario) => total + funcionario.total,
    );
  }

  Map<String, List<FuncionarioMes>> get funcionariosAgrupados {
    final Map<String, List<FuncionarioMes>> grupos = {};

    for (final funcionario in funcionarios) {
      final cargo = funcionario.cargo;

      if (!grupos.containsKey(cargo)) {
        grupos[cargo] = [];
      }

      grupos[cargo]!.add(funcionario);
    }

    return grupos;
  }

  void limparCampos() {
    nomeController.clear();
    cargoController.clear();
    salarioController.clear();
    horaExtraController.clear();
    comissaoController.clear();
    observacaoController.clear();
  }

  void abrirModalAdicionarFuncionario() {
    limparCampos();

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
                MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Adicionar funcionário',
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
                  controller: cargoController,
                  decoration: const InputDecoration(
                    labelText: 'Cargo',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: salarioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Salário',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: horaExtraController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hora extra',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: comissaoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Comissão (%)',
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
                    onPressed: salvarFuncionario,
                    child: const Text(
                      'Salvar funcionário',
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

  void salvarFuncionario() {
    final nome = nomeController.text.trim();
    final cargo = cargoController.text.trim();

    if (nome.isEmpty || cargo.isEmpty) {
      return;
    }

    final funcionario = FuncionarioMes(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      nome: nome,
      cargo: cargo,
      salarioBase:
          converterValor(salarioController.text),
      horaExtra:
          converterValor(horaExtraController.text),
      comissao:
          converterValor(comissaoController.text),
      observacao:
          observacaoController.text.trim(),
    );

    setState(() {
      funcionarios.add(funcionario);
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nomeController.dispose();
    cargoController.dispose();
    salarioController.dispose();
    horaExtraController.dispose();
    comissaoController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grupos = funcionariosAgrupados;

    return Scaffold(
      backgroundColor: const Color(0xFFE9E4DF),

      body: funcionarios.isEmpty
          ? const Center(
              child: Text(
                'Nenhum funcionário cadastrado.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: grupos.entries.map((grupo) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: Text(
                        grupo.key,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    ...grupo.value.map((funcionario) {
                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  funcionario.nome,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  funcionario.cargo,
                                  style: TextStyle(
                                    color:
                                        Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              'R\$ ${funcionario.total.toStringAsFixed(2)}',
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

                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),

      bottomNavigationBar: Container(
        color: const Color(0xFFE9E4DF),
        padding: const EdgeInsets.all(20),
        child: Text(
          'Total da folha: R\$ ${totalFolha.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC2463C),
        onPressed:
            abrirModalAdicionarFuncionario,
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