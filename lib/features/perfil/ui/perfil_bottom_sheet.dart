import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/perfil/model/perfil.dart';

class PerfilBottomSheet extends StatefulWidget {
  const PerfilBottomSheet({super.key});

  @override
  State<PerfilBottomSheet> createState() => _PerfilBottomSheetState();
}

class _PerfilBottomSheetState extends State<PerfilBottomSheet> {
  final supabase = Supabase.instance.client;
  Perfil? _perfil;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('perfis')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _perfil = Perfil.fromMap(data);
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  Future<void> _sair() async {
    Navigator.pop(context);
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Alça
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFC2463C).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 32,
              color: Color(0xFFC2463C),
            ),
          ),
          const SizedBox(height: 16),

          // Dados do perfil
          if (_carregando)
            const CircularProgressIndicator(color: Color(0xFFC2463C))
          else ...[
            if (_perfil != null)
              Text(
                _perfil!.nomeRestaurante,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            if (_perfil?.telefone != null) ...[
              const SizedBox(height: 4),
              Text(
                _perfil!.telefone,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
            if (_perfil?.cnpj != null) ...[
              const SizedBox(height: 4),
              Text(
                'CNPJ: ${_perfil!.cnpj}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          // Botão sair
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
            onTap: _sair,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}