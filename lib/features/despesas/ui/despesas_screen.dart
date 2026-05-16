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
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
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
        body: const TabBarView(
          children: [
            FuncionariosTab(),
            RecorrentesTab(),
            NormaisTab(),
          ],
        ),
      ),
    );
  }
}