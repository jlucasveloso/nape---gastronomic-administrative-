import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';
import 'package:proj_nape/repositories/venda_repository.dart';
import 'package:proj_nape/repositories/despesa_repository.dart';
import 'package:proj_nape/repositories/cardapio_repository.dart';

class AppState extends ChangeNotifier {
  // ── Repositórios ──────────────────────────────────────────────────────────
  final _vendaRepo = VendaRepository();
  final _despesaRepo = DespesaRepository();
  final _cardapioRepo = CardapioRepository();

  // ── Dados centrais ────────────────────────────────────────────────────────
  List<ProdutoCardapio> _cardapio = [];
  List<Venda> _vendas = [];
  List<Despesa> _despesas = [];
  bool carregando = false;

  // ── Getters (leitura) ─────────────────────────────────────────────────────
  List<ProdutoCardapio> get cardapio => List.unmodifiable(_cardapio);
  List<Venda> get vendas => List.unmodifiable(_vendas);
  List<Despesa> get despesas => List.unmodifiable(_despesas);

  // ── Carregar todos os dados do Supabase ───────────────────────────────────
  Future<void> carregarDados() async {
    carregando = true;
    notifyListeners();

    try {
      _vendas = await _vendaRepo.buscarVendas();
      _despesas = await _despesaRepo.buscarDespesas();
      _cardapio = await _cardapioRepo.buscarProdutos();
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // ── Cardápio ──────────────────────────────────────────────────────────────

  Future<void> adicionarProduto(ProdutoCardapio produto) async {
    final novo = await _cardapioRepo.adicionarProduto(produto);
    _cardapio.add(novo);
    notifyListeners();
  }

  Future<void> desativarProduto(String id) async {
    await _cardapioRepo.desativarProduto(id);
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

Future<void> editarProduto(ProdutoCardapio produto) async {
  await _cardapioRepo.atualizarProduto(produto);
  final index = _cardapio.indexWhere((p) => p.id == produto.id);
  if (index != -1) {
    _cardapio[index] = produto;
    notifyListeners();
  }
}

Future<void> deletarProduto(String id) async {
  await _cardapioRepo.deletarProduto(id);
  _cardapio.removeWhere((p) => p.id == id);
  notifyListeners();
}
  // ── Vendas ────────────────────────────────────────────────────────────────

  Future<void> adicionarVenda(Venda venda) async {
    final nova = await _vendaRepo.adicionarVenda(venda);
    _vendas.add(nova);
    notifyListeners();
  }

  Future<void> deletarVenda(String id) async {
    await _vendaRepo.deletarVenda(id);
    _vendas.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // ── Despesas ──────────────────────────────────────────────────────────────

  Future<void> adicionarDespesa(Despesa despesa) async {
    final nova = await _despesaRepo.adicionarDespesa(despesa);
    _despesas.add(nova);
    notifyListeners();
  }

  Future<void> deletarDespesa(String id) async {
    await _despesaRepo.deletarDespesa(id);
    _despesas.removeWhere((d) => d.id == id);
    notifyListeners();
  }
}