import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';

class AppState extends ChangeNotifier {
  // ── Dados centrais ────────────────────────────────────────────────────────

  final List<ProdutoCardapio> _cardapio = [];
  final List<Venda> _vendas = [];
  final List<Despesa> _despesas = [];

  // ── Getters (leitura) ─────────────────────────────────────────────────────

  List<ProdutoCardapio> get cardapio => List.unmodifiable(_cardapio);
  List<Venda> get vendas => List.unmodifiable(_vendas);
  List<Despesa> get despesas => List.unmodifiable(_despesas);

  // ── Cardápio ──────────────────────────────────────────────────────────────

  void adicionarProduto(ProdutoCardapio produto) {
    _cardapio.add(produto);
    notifyListeners();
  }

  void desativarProduto(String id) {
    final index = _cardapio.indexWhere((p) => p.id == id);
    if (index != -1) {
      _cardapio[index] = ProdutoCardapio(
        id: _cardapio[index].id,
        nome: _cardapio[index].nome,
        categoria: _cardapio[index].categoria,
        preco: _cardapio[index].preco,
        ativo: false,
        dataCadastro: _cardapio[index].dataCadastro,
      );
      notifyListeners();
    }
  }

  // ── Vendas ────────────────────────────────────────────────────────────────

  void adicionarVenda(Venda venda) {
    _vendas.add(venda);
    notifyListeners();
  }

  // ── Despesas ──────────────────────────────────────────────────────────────

  void adicionarDespesa(Despesa despesa) {
    _despesas.add(despesa);
    notifyListeners();
  }
}