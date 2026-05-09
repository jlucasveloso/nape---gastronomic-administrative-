import 'package:flutter/material.dart';
import 'package:proj_nape/main.dart';
import 'package:proj_nape/shared/temp_auth.dart';

class PerfilBottomSheet extends StatelessWidget {
  const PerfilBottomSheet({super.key});

  void _sair(BuildContext context) {
    TempAuth.logout();

    Navigator.pop(context);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius:
                  BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFC2463C)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 32,
              color: Color(0xFFC2463C),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Usuário Local',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Modo temporário',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 24),

          const Divider(),

          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color(0xFFC2463C),
            ),
            title: const Text(
              'Sair',
              style: TextStyle(
                color: Color(0xFFC2463C),
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _sair(context),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}