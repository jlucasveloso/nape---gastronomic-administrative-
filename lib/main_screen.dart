import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj_nape/app_state.dart';
import 'package:proj_nape/features/dashboard/ui/dashboard_screen.dart';
import 'package:proj_nape/features/dashboard/ui/faturamento_screen.dart';
import 'package:proj_nape/features/dashboard/ui/despesas_screen.dart';
import 'package:proj_nape/features/dashboard/ui/lucro_screen.dart';
import 'package:proj_nape/features/dashboard/ui/cardapio_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceAtivo = 0;

  final List<Widget> _telas = const [
    DashboardScreen(),
    FaturamentoScreen(),
    DespesasScreen(),
    LucroScreen(),
    CardapioScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().carregarDados();
    });
  }

  Future<void> _sair() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_indiceAtivo],
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
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Vendas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_down_outlined),
            activeIcon: Icon(Icons.trending_down),
            label: 'Despesas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Lucro',
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