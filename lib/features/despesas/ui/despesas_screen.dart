import 'package:flutter/material.dart';

import 'funcionarios_tab.dart';
import 'recorrentes_tab.dart';
import 'normais_tab.dart';

class DespesasScreen extends StatelessWidget {
  const DespesasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFE9E4DF),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: const Text(
            'Despesas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFFC2463C),
            unselectedLabelColor: Colors.black54,
            indicatorColor: Color(0xFFC2463C),
            tabs: [
              Tab(text: 'Funcionários'),
              Tab(text: 'Recorrentes'),
              Tab(text: 'Normais'),
            ],
          ),
        ),
        body: Column(
          children: const [
            _ResumoDespesas(),
            Expanded(
              child: TabBarView(
                children: [
                  FuncionariosTab(),
                  RecorrentesTab(),
                  NormaisTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoDespesas extends StatelessWidget {
  const _ResumoDespesas();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _ResumoItem(
            titulo: 'Funcionários',
            valor: '12',
            icone: Icons.people_alt_outlined,
          ),
          _ResumoItem(
            titulo: 'Recorrentes',
            valor: '8',
            icone: Icons.repeat_rounded,
          ),
          _ResumoItem(
            titulo: 'Normais',
            valor: '15',
            icone: Icons.receipt_long_outlined,
          ),
        ],
      ),
    );
  }
}

class _ResumoItem extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _ResumoItem({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icone,
          color: const Color(0xFFC2463C),
          size: 30,
        ),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}