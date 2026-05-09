import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/perfil/model/perfil.dart';

class PerfilRepository {
  final _supabase = Supabase.instance.client;

  // Busca todos os perfis — só funciona para admin
  Future<List<Perfil>> buscarTodosPerfis() async {
    final data = await _supabase
        .from('perfis')
        .select()
        .order('created_at', ascending: false);

    return data.map((map) => Perfil.fromMap(map)).toList();
  }

  // Busca o perfil do usuário logado
  Future<Perfil?> buscarPerfilAtual() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('perfis')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return Perfil.fromMap(data);
  }
}