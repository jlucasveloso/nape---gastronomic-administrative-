import 'package:flutter/material.dart';
import 'package:proj_nape/features/perfil/model/perfil.dart';

class AdminRestauranteScreen extends StatefulWidget {
  final Perfil perfil;

  const AdminRestauranteScreen({super.key, required this.perfil});

  @override
  State<AdminRestauranteScreen> createState() =>
      _AdminRestauranteScreenState();
}

class _AdminRestauranteScreenState extends State<AdminRestauranteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E4DF),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
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
                // Botão voltar
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.perfil.nomeRestaurante,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.perfil.telefone,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Abas ──────────────────────────────────────────────────
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Dashboard'),
                    Tab(text: 'Dados'),
                    Tab(text: 'Cardápio'),
                  ],
                ),
              ],
            ),
          ),

          // ── Conteúdo das abas ─────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aba Dashboard
                _AbaPlaceholder(
                  icone: Icons.dashboard_outlined,
                  titulo: 'Dashboard',
                  subtitulo: 'Em breve',
                ),

                // Aba Dados (Vendas e Despesas em tabela)
                _AbaPlaceholder(
                  icone: Icons.table_chart_outlined,
                  titulo: 'Dados',
                  subtitulo: 'Em breve',
                ),

                // Aba Cardápio
                _AbaPlaceholder(
                  icone: Icons.restaurant_menu_outlined,
                  titulo: 'Cardápio',
                  subtitulo: 'Em breve',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder para abas ainda não implementadas ─────────────────────────────

class _AbaPlaceholder extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;

  const _AbaPlaceholder({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
  });

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
            child: Icon(
              icone,
              size: 36,
              color: const Color(0xFFC2463C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}