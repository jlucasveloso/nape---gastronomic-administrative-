import 'package:flutter/material.dart';
import 'package:proj_nape/features/perfil/model/perfil.dart';
import 'package:proj_nape/features/admin/ui/abas/admin_analise_aba.dart';
import 'package:proj_nape/features/admin/ui/abas/admin_dados_aba.dart';
import 'package:proj_nape/features/admin/ui/abas/admin_cardapio_aba.dart';

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
      AdminAnaliseAba(userId: widget.perfil.id),
      AdminDadosAba(userId: widget.perfil.id),
      AdminCardapioAba(userId: widget.perfil.id),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE9E4DF),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              _indiceAtivo == 1 ? MediaQuery.of(context).padding.top + 8 : 52,
              16,
              _indiceAtivo == 1 ? 8 : 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFC2463C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: _indiceAtivo == 1
                // Header mínimo — aba Dados
                ? Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios,
                            color: Colors.white70, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.perfil.nomeRestaurante,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                // Header normal — outras abas
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Análise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart_outlined),
            activeIcon: Icon(Icons.table_chart),
            label: 'Dados',
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