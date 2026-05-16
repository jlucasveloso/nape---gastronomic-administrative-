import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/dashboard/model/categoria_despesa.dart';

class CategoriaDespesaRepository {
  final _supabase = Supabase.instance.client;

  String _resolverUserId(String? userId) {
    return userId ?? _supabase.auth.currentUser!.id;
  }

  Future<List<CategoriaDespesa>> buscarCategorias({String? userId}) async {
    final id = _resolverUserId(userId);

    final data = await _supabase
        .from('categorias_despesa')
        .select()
        .eq('user_id', id)
        .order('nome', ascending: true);

    return data.map((map) => CategoriaDespesa.fromMap(map)).toList();
  }

  Future<CategoriaDespesa> adicionarCategoria(
    CategoriaDespesa categoria, {
    String? userId,
  }) async {
    final id = _resolverUserId(userId);

    final data = await _supabase.from('categorias_despesa').insert({
      'user_id': id,
      ...categoria.toMap(),
    }).select().single();

    return CategoriaDespesa.fromMap(data);
  }

  Future<void> atualizarCategoria(CategoriaDespesa categoria) async {
    await _supabase
        .from('categorias_despesa')
        .update(categoria.toMap())
        .eq('id', categoria.id);
  }

  Future<void> deletarCategoria(String id) async {
    await _supabase.from('categorias_despesa').delete().eq('id', id);
  }
}