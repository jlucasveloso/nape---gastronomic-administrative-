import 'package:flutter/material.dart';
import 'package:proj_nape/shared/widgets/info_card.dart';
import 'package:proj_nape/features/dashboard/ui/faturamento_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InfoCard(
          title: 'Faturamento',
          icon: Icons.attach_money,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FaturamentoScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}