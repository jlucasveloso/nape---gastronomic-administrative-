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
    }).select().single();

    return Despesa(
      id: data['id'],
      descricao: data['descricao'],
      categoria: data['categoria'],
      valor: (data['valor'] as num).toDouble(),
      data: DateTime.parse(data['data']),
    );
  }

  Future<void> atualizarDespesa(Despesa despesa) async {
    await _supabase.from('despesas').update({
      'descricao': despesa.descricao,
      'categoria': despesa.categoria,
      'valor': despesa.valor,
      'data': despesa.data.toIso8601String(),
    }).eq('id', despesa.id);
  }

  Future<void> deletarDespesa(String id) async {
    await _supabase.from('despesas').delete().eq('id', id);
  }
}