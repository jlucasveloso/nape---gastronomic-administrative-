import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';
import 'package:proj_nape/shared/temp_auth.dart';

class AppState extends ChangeNotifier {
  final Map<String, List<ProdutoCardapio>> _cardapioPorCliente = {};
  final Map<String, List<Venda>> _vendasPorCliente = {};
  final Map<String, List<Despesa>> _despesasPorCliente = {};

  bool carregando = false;

  String get _clienteId => TempAuth.emailAtual ?? 'cliente_local';

  List<ProdutoCardapio> get cardapio {
    return List.unmodifiable(_cardapioPorCliente[_clienteId] ?? []);
  }

  List<Venda> get vendas {
    return List.unmodifiable(_vendasPorCliente[_clienteId] ?? []);
  }

  List<Despesa> get despesas {
    return List.unmodifiable(_despesasPorCliente[_clienteId] ?? []);
  }

  Future<void> carregarDados() async {
    carregando = true;
    notifyListeners();

    _cardapioPorCliente.putIfAbsent(_clienteId, () => []);
    _vendasPorCliente.putIfAbsent(_clienteId, () => []);
    _despesasPorCliente.putIfAbsent(_clienteId, () => []);

    await Future.delayed(const Duration(milliseconds: 300));

    carregando = false;
    notifyListeners();
  }

  Future<void> adicionarProduto(ProdutoCardapio produto) async {
    final lista = _cardapioPorCliente.putIfAbsent(_clienteId, () => []);

    final novoProduto = ProdutoCardapio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: produto.nome,
      categoria: produto.categoria,
      preco: produto.preco,
      ativo: true,
      dataCadastro: DateTime.now(),
    );

    lista.add(novoProduto);
    notifyListeners();
  }

  Future<void> editarProduto(ProdutoCardapio produto) async {
    final lista = _cardapioPorCliente.putIfAbsent(_clienteId, () => []);
    final index = lista.indexWhere((p) => p.id == produto.id);

    if (index != -1) {
      lista[index] = produto;
      notifyListeners();
    }
  }

  Future<void> deletarProduto(String id) async {
    final lista = _cardapioPorCliente.putIfAbsent(_clienteId, () => []);
    lista.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> adicionarVenda(Venda venda) async {
    final lista = _vendasPorCliente.putIfAbsent(_clienteId, () => []);

    final novaVenda = Venda(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      produtoId: venda.produtoId,
      nomeProdutoSnapshot: venda.nomeProdutoSnapshot,
      categoriaSnapshot: venda.categoriaSnapshot,
      precoUnitarioSnapshot: venda.precoUnitarioSnapshot,
      quantidade: venda.quantidade,
      data: DateTime.now(),
    );

    lista.add(novaVenda);
    notifyListeners();
  }

  Future<void> deletarVenda(String id) async {
    final lista = _vendasPorCliente.putIfAbsent(_clienteId, () => []);
    lista.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  Future<void> adicionarDespesa(Despesa despesa) async {
    final lista = _despesasPorCliente.putIfAbsent(_clienteId, () => []);

    final novaDespesa = Despesa(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      descricao: despesa.descricao,
      categoria: despesa.categoria,
      valor: despesa.valor,
      data: DateTime.now(),
      tipo: despesa.tipo,
      observacao: despesa.observacao,
    );

    lista.add(novaDespesa);
    notifyListeners();
  }

  Future<void> deletarDespesa(String id) async {
    final lista = _despesasPorCliente.putIfAbsent(_clienteId, () => []);
    lista.removeWhere((d) => d.id == id);
    notifyListeners();
  }
}