import 'package:flutter/material.dart';
import 'package:proj_nape/features/perfil/model/perfil.dart';

class AdminRestauranteScreen extends StatefulWidget {
  final Perfil perfil;

  const AdminRestauranteScreen({super.key, required this.perfil});

  @override
  State<AdminRestauranteScreen> createState() =>
      _AdminRestauranteScreenState();
}

class _AdminRestauranteScreenState extends State<AdminRestauranteScreen> {
  int _indiceAtivo = 0;

  @override
  Widget build(BuildContext context) {
    final telas = [
      _AbaPlaceholder(
        icone: Icons.dashboard_outlined,
        titulo: 'Dashboard',
        subtitulo: 'Em breve',
      ),
      _AbaPlaceholder(
        icone: Icons.table_chart_outlined,
        titulo: 'Análise',
        subtitulo: 'Em breve',
      ),
      _AbaPlaceholder(
        icone: Icons.restaurant_menu_outlined,
        titulo: 'Cardápio',
        subtitulo: 'Em breve',
      ),
    ];

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
                // Botão voltar para lista de restaurantes
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back_ios,
                          color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Restaurantes',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
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
              ],
            ),
          ),

          // ── Conteúdo ──────────────────────────────────────────────────────
          Expanded(
            child: telas[_indiceAtivo],
          ),
        ],
      ),

      // ── Bottom nav ────────────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtivo,
        onTap: (indice) => setState(() => _indiceAtivo = indice),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFC2463C),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart_outlined),
            activeIcon: Icon(Icons.table_chart),
            label: 'Análise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Cardápio',
          ),
        ],
      ),
    );
  }
}

// ── Placeholder ───────────────────────────────────────────────────────────────

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
            child: Icon(icone, size: 36, color: const Color(0xFFC2463C)),
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
            style: const TextStyle(fontSize: 13, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}