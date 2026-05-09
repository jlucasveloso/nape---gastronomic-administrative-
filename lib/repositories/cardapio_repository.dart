import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';

class CardapioRepository {
  final _supabase = Supabase.instance.client;

  String _resolverUserId(String? userId) {
    return userId ?? _supabase.auth.currentUser!.id;
  }

  Future<List<ProdutoCardapio>> buscarProdutos({String? userId}) async {
    final id = _resolverUserId(userId);

    final data = await _supabase
        .from('produtos_cardapio')
        .select()
        .eq('user_id', id)
        .order('nome', ascending: true);

    return data.map((map) => ProdutoCardapio(
      id: map['id'],
      nome: map['nome'],
      categoria: map['categoria'],
      preco: (map['preco'] as num).toDouble(),
      ativo: map['ativo'],
      dataCadastro: DateTime.parse(map['data_cadastro']),
    )).toList();
  }

  Future<ProdutoCardapio> adicionarProduto(ProdutoCardapio produto,
      {String? userId}) async {
    final id = _resolverUserId(userId);

    final data = await _supabase.from('produtos_cardapio').insert({
      'user_id': id,
      'nome': produto.nome,
      'categoria': produto.categoria,
      'preco': produto.preco,
      'ativo': produto.ativo,
    }).select().single();

    return ProdutoCardapio(
      id: data['id'],
      nome: data['nome'],
      categoria: data['categoria'],
      preco: (data['preco'] as num).toDouble(),
      ativo: data['ativo'],
      dataCadastro: DateTime.parse(data['data_cadastro']),
    );
  }

  Future<void> atualizarProduto(ProdutoCardapio produto) async {
    await _supabase.from('produtos_cardapio').update({
      'nome': produto.nome,
      'categoria': produto.categoria,
      'preco': produto.preco,
      'ativo': produto.ativo,
    }).eq('id', produto.id);
  }

  Future<void> deletarProduto(String id) async {
    await _supabase.from('produtos_cardapio').delete().eq('id', id);
  }
}