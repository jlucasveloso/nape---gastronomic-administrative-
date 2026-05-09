import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';

class VendaRepository {
  final _supabase = Supabase.instance.client;

  // Se userId for passado (admin), busca dados daquele restaurante
  // Se não for passado, usa o usuário logado
  String _resolverUserId(String? userId) {
    return userId ?? _supabase.auth.currentUser!.id;
  }

  Future<List<Venda>> buscarVendas({String? userId}) async {
    final id = _resolverUserId(userId);

    final data = await _supabase
        .from('vendas')
        .select()
        .eq('user_id', id)
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

  Future<Venda> adicionarVenda(Venda venda, {String? userId}) async {
    final id = _resolverUserId(userId);

    final data = await _supabase.from('vendas').insert({
      'user_id': id,
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

  Future<void> atualizarVenda(Venda venda) async {
    await _supabase.from('vendas').update({
      'nome_produto_snapshot': venda.nomeProdutoSnapshot,
      'categoria_snapshot': venda.categoriaSnapshot,
      'preco_unitario_snapshot': venda.precoUnitarioSnapshot,
      'quantidade': venda.quantidade,
      'data': venda.data.toIso8601String(),
    }).eq('id', venda.id);
  }

  Future<void> deletarVenda(String id) async {
    await _supabase.from('vendas').delete().eq('id', id);
  }
}