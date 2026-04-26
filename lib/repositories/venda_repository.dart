import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';

class VendaRepository {
  final _supabase = Supabase.instance.client;

  // Busca todas as vendas do usuário logado
  Future<List<Venda>> buscarVendas() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('vendas')
        .select()
        .eq('user_id', userId)
        .order('data', ascending: false);

    return data.map((map) => Venda(
      id: map['id'],
      produtoId: map['produto_id'],
      nomeProdutoSnapshot: map['nome_produto_snapshot'],
      categoriaSnapshot: map['categoria_snapshot'],
      precoUnitarioSnapshot: (map['preco_unitario_snapshot'] as num).toDouble(),
      quantidade: map['quantidade'],
      data: DateTime.parse(map['data']),
    )).toList();
  }

  // Adiciona uma venda no Supabase
  Future<Venda> adicionarVenda(Venda venda) async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase.from('vendas').insert({
      'user_id': userId,
      'produto_id': venda.produtoId,
      'nome_produto_snapshot': venda.nomeProdutoSnapshot,
      'categoria_snapshot': venda.categoriaSnapshot,
      'preco_unitario_snapshot': venda.precoUnitarioSnapshot,
      'quantidade': venda.quantidade,
      'data': venda.data.toIso8601String(),
    }).select().single();

    return Venda(
      id: data['id'],
      produtoId: data['produto_id'],
      nomeProdutoSnapshot: data['nome_produto_snapshot'],
      categoriaSnapshot: data['categoria_snapshot'],
      precoUnitarioSnapshot: (data['preco_unitario_snapshot'] as num).toDouble(),
      quantidade: data['quantidade'],
      data: DateTime.parse(data['data']),
    );
  }

  // Deleta uma venda
  Future<void> deletarVenda(String id) async {
    await _supabase.from('vendas').delete().eq('id', id);
  }
}