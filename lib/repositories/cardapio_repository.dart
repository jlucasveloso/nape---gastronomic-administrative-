import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';

class CardapioRepository {
  final _supabase = Supabase.instance.client;

  // Busca todos os produtos do cardápio do usuário logado
  Future<List<ProdutoCardapio>> buscarProdutos() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('produtos_cardapio')
        .select()
        .eq('user_id', userId)
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

  // Adiciona um produto no Supabase
  Future<ProdutoCardapio> adicionarProduto(ProdutoCardapio produto) async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase.from('produtos_cardapio').insert({
      'user_id': userId,
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

  // Atualiza um produto
  Future<void> atualizarProduto(ProdutoCardapio produto) async {
    await _supabase.from('produtos_cardapio').update({
      'nome': produto.nome,
      'categoria': produto.categoria,
      'preco': produto.preco,
      'ativo': produto.ativo,
    }).eq('id', produto.id);
  }

  // Desativa um produto (soft delete)
  Future<void> desativarProduto(String id) async {
    await _supabase
        .from('produtos_cardapio')
        .update({'ativo': false})
        .eq('id', id);
  }

// Deleta um produto (hard delete)
  Future<void> deletarProduto(String id) async {
  await _supabase.from('produtos_cardapio').delete().eq('id', id);
}
}
