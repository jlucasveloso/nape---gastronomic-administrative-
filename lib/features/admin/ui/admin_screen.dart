import 'package:flutter/material.dart';
import 'package:proj_nape/features/perfil/model/perfil.dart';
import 'package:proj_nape/repositories/perfil_repository.dart';
import 'package:proj_nape/features/admin/ui/admin_restaurante_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _perfilRepo = PerfilRepository();
  List<Perfil> _perfis = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarRestaurantes();
  }

  Future<void> _carregarRestaurantes() async {
    try {
      final perfis = await _perfilRepo.buscarTodosPerfis();
      setState(() {
        _perfis = perfis;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      debugPrint('Erro ao carregar restaurantes: $e');
    }
  }

  Future<void> _sair() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final fmtData = DateFormat('dd/MM/yyyy', 'pt_BR');

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Painel Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Napê Consultoria',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                // Botão sair
                GestureDetector(
                  onTap: _sair,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Sair',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Conteúdo ──────────────────────────────────────────────────────
          Expanded(
            child: _carregando
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC2463C),
                    ),
                  )
                : _perfis.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum restaurante cadastrado ainda.',
                          style: TextStyle(color: Colors.black38),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _perfis.length,
                        itemBuilder: (context, index) {
                          final perfil = _perfis[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminRestauranteScreen(
                                    perfil: perfil,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Ícone
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC2463C)
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant_outlined,
                                      color: Color(0xFFC2463C),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Informações
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          perfil.nomeRestaurante,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          perfil.telefone,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black38,
                                          ),
                                        ),
                                        if (perfil.cnpj != null)
                                          Text(
                                            'CNPJ: ${perfil.cnpj}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black38,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Data e seta
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        fmtData.format(perfil.createdAt),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black38,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}