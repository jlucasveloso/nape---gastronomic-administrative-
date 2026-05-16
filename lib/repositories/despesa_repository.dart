import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';

class DespesaRepository {
  final _supabase = Supabase.instance.client;

  String _resolverUserId(String? userId) {
    return userId ?? _supabase.auth.currentUser!.id;
  }

  Future<List<Despesa>> buscarDespesas({String? userId}) async {
    final id = _resolverUserId(userId);

    final data = await _supabase
        .from('despesas')
        .select()
        .eq('user_id', id)
        .order('data', ascending: false);

    return data.map((map) => Despesa(
      id: map['id'],
      descricao: map['descricao'],
      categoria: map['categoria'],
      valor: (map['valor'] as num).toDouble(),
      data: DateTime.parse(map['data']),
      observacao: map['observacao'],
      categoriaId: map['categoria_id'],
      tipo: map['tipo'] ?? 'outros',
    )).toList();
  }

  Future<Despesa> adicionarDespesa(Despesa despesa, {String? userId}) async {
    final id = _resolverUserId(userId);

    final data = await _supabase.from('despesas').insert({
      'user_id': id,
      'descricao': despesa.descricao,
      'categoria': despesa.categoria,
      'valor': despesa.valor,
      'data': despesa.data.toIso8601String(),
      'observacao': despesa.observacao,
      'categoria_id': despesa.categoriaId,
      'tipo': despesa.tipo,
    }).select().single();

    return Despesa(
      id: data['id'],
      descricao: data['descricao'],
      categoria: data['categoria'],
      valor: (data['valor'] as num).toDouble(),
      data: DateTime.parse(data['data']),
      observacao: data['observacao'],
      categoriaId: data['categoria_id'],
      tipo: data['tipo'] ?? 'outros',
    );
  }

  Future<void> atualizarDespesa(Despesa despesa) async {
    await _supabase.from('despesas').update({
      'descricao': despesa.descricao,
      'categoria': despesa.categoria,
      'valor': despesa.valor,
      'data': despesa.data.toIso8601String(),
      'observacao': despesa.observacao,
      'categoria_id': despesa.categoriaId,
      'tipo': despesa.tipo,
    }).eq('id', despesa.id);
  }

  Future<void> deletarDespesa(String id) async {
    await _supabase.from('despesas').delete().eq('id', id);
  }
}