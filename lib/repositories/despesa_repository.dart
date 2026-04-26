import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';

class DespesaRepository {
  final _supabase = Supabase.instance.client;

  // Busca todas as despesas do usuário logado
  Future<List<Despesa>> buscarDespesas() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('despesas')
        .select()
        .eq('user_id', userId)
        .order('data', ascending: false);

    return data.map((map) => Despesa(
      id: map['id'],
      descricao: map['descricao'],
      categoria: map['categoria'],
      valor: (map['valor'] as num).toDouble(),
      data: DateTime.parse(map['data']),
    )).toList();
  }

  // Adiciona uma despesa no Supabase
  Future<Despesa> adicionarDespesa(Despesa despesa) async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase.from('despesas').insert({
      'user_id': userId,
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

  // Deleta uma despesa
  Future<void> deletarDespesa(String id) async {
    await _supabase.from('despesas').delete().eq('id', id);
  }
}