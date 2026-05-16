import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proj_nape/app_state.dart';
import 'package:proj_nape/features/dashboard/ui/dashboard_screen.dart';
import 'package:proj_nape/features/dashboard/ui/faturamento_screen.dart';
import 'package:proj_nape/features/despesas/ui/despesas_screen.dart';
import 'package:proj_nape/features/dashboard/ui/lucro_screen.dart';
import 'package:proj_nape/features/dashboard/ui/cardapio_screen.dart';
import 'package:proj_nape/features/dashboard/ui/analise_screen.dart';

final mainScreenKey = GlobalKey<MainScreenState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _indiceAtivo = 0;

  void trocarAba(int indice) {
    setState(() => _indiceAtivo = indice);
  }

  final List<Widget> _telas = const [
    DashboardScreen(),
    FaturamentoScreen(),
    DespesasScreen(),
    LucroScreen(),
    AnaliseScreen(),
    CardapioScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().carregarDados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_indiceAtivo],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtivo == 4
            ? 1
            : _indiceAtivo == 5
                ? 2
                : 0,
        onTap: (indice) {
          if (indice == 0) trocarAba(0);
          if (indice == 1) trocarAba(4);
          if (indice == 2) trocarAba(5);
        },
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
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
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