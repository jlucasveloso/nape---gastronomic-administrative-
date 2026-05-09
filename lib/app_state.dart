import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';

class AppState extends ChangeNotifier {
  final List<ProdutoCardapio> _cardapio = [];
  final List<Venda> _vendas = [];
  final List<Despesa> _despesas = [];

  bool carregando = false;

  List<ProdutoCardapio> get cardapio =>
      List.unmodifiable(_cardapio);

  List<Venda> get vendas =>
      List.unmodifiable(_vendas);

  List<Despesa> get despesas =>
      List.unmodifiable(_despesas);

  Future<void> carregarDados() async {
    carregando = true;
    notifyListeners();

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    carregando = false;
    notifyListeners();
  }

  // Cardápio

  Future<void> adicionarProduto(
    ProdutoCardapio produto,
  ) async {
    final novoProduto = ProdutoCardapio(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      nome: produto.nome,
      categoria: produto.categoria,
      preco: produto.preco,
      ativo: true,
      dataCadastro: DateTime.now(),
    );

    _cardapio.add(novoProduto);

    notifyListeners();
  }

  Future<void> editarProduto(
    ProdutoCardapio produto,
  ) async {
    final index = _cardapio.indexWhere(
      (p) => p.id == produto.id,
    );

    if (index != -1) {
      _cardapio[index] = produto;
      notifyListeners();
    }
  }

  Future<void> deletarProduto(
    String id,
  ) async {
    _cardapio.removeWhere(
      (p) => p.id == id,
    );

    notifyListeners();
  }

  // Vendas

  Future<void> adicionarVenda(
    Venda venda,
  ) async {
    final novaVenda = Venda(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      produtoId: venda.produtoId,
      nomeProdutoSnapshot:
          venda.nomeProdutoSnapshot,
      categoriaSnapshot:
          venda.categoriaSnapshot,
      precoUnitarioSnapshot:
          venda.precoUnitarioSnapshot,
      quantidade: venda.quantidade,
      data: DateTime.now(),
    );

    _vendas.add(novaVenda);

    notifyListeners();
  }

  Future<void> deletarVenda(
    String id,
  ) async {
    _vendas.removeWhere(
      (v) => v.id == id,
    );

    notifyListeners();
  }

  // Despesas

  Future<void> adicionarDespesa(
    Despesa despesa,
  ) async {
    final novaDespesa = Despesa(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      descricao: despesa.descricao,
      categoria: despesa.categoria,
      valor: despesa.valor,
      data: DateTime.now(),
      observacao: despesa.observacao,
    );

    _despesas.add(novaDespesa);

    notifyListeners();
  }

  Future<void> deletarDespesa(
    String id,
  ) async {
    _despesas.removeWhere(
      (d) => d.id == id,
    );

    notifyListeners();
  }
}