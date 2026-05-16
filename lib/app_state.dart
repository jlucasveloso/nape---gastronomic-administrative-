import 'package:flutter/material.dart';
import 'package:proj_nape/features/dashboard/model/despesa.dart';
import 'package:proj_nape/features/dashboard/model/produto_cardapio.dart';
import 'package:proj_nape/features/dashboard/model/venda.dart';
import 'package:proj_nape/features/dashboard/model/categoria_despesa.dart';
import 'package:proj_nape/features/dashboard/model/despesa_recorrente.dart';
import 'package:proj_nape/features/dashboard/model/registro_recorrente.dart';
import 'package:proj_nape/features/dashboard/model/funcionario.dart';
import 'package:proj_nape/features/dashboard/model/pagamento_funcionario.dart';
import 'package:proj_nape/repositories/venda_repository.dart';
import 'package:proj_nape/repositories/despesa_repository.dart';
import 'package:proj_nape/repositories/cardapio_repository.dart';
import 'package:proj_nape/repositories/categoria_despesa_repository.dart';
import 'package:proj_nape/repositories/despesa_recorrente_repository.dart';
import 'package:proj_nape/repositories/funcionario_repository.dart';

class AppState extends ChangeNotifier {
  // ── Repositórios ──────────────────────────────────────────────────────────
  final _vendaRepo = VendaRepository();
  final _despesaRepo = DespesaRepository();
  final _cardapioRepo = CardapioRepository();
  final _categoriaRepo = CategoriaDespesaRepository();
  final _recorrenteRepo = DespesaRecorrenteRepository();
  final _funcionarioRepo = FuncionarioRepository();

  // ── Dados centrais ────────────────────────────────────────────────────────
  List<ProdutoCardapio> _cardapio = [];
  List<Venda> _vendas = [];
  List<Despesa> _despesas = [];
  List<CategoriaDespesa> _categorias = [];
  List<DespesaRecorrente> _recorrentes = [];
  List<RegistroRecorrente> _registrosRecorrentes = [];
  List<Funcionario> _funcionarios = [];
  List<PagamentoFuncionario> _pagamentos = [];
  bool carregando = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<ProdutoCardapio> get cardapio => List.unmodifiable(_cardapio);
  List<Venda> get vendas => List.unmodifiable(_vendas);
  List<Despesa> get despesas => List.unmodifiable(_despesas);
  List<CategoriaDespesa> get categorias => List.unmodifiable(_categorias);
  List<DespesaRecorrente> get recorrentes => List.unmodifiable(_recorrentes);
  List<RegistroRecorrente> get registrosRecorrentes => List.unmodifiable(_registrosRecorrentes);
  List<Funcionario> get funcionarios => List.unmodifiable(_funcionarios);
  List<PagamentoFuncionario> get pagamentos => List.unmodifiable(_pagamentos);

  // ── Carregar todos os dados ───────────────────────────────────────────────
  Future<void> carregarDados() async {
    carregando = true;
    notifyListeners();

    try {
      final competenciaAtual = _competenciaAtual();

      final results = await Future.wait([
        _vendaRepo.buscarVendas(),
        _despesaRepo.buscarDespesas(),
        _cardapioRepo.buscarProdutos(),
        _categoriaRepo.buscarCategorias(),
        _recorrenteRepo.buscarRecorrentes(),
        _recorrenteRepo.buscarRegistros(competencia: competenciaAtual),
        _funcionarioRepo.buscarFuncionarios(),
        _funcionarioRepo.buscarPagamentos(competencia: competenciaAtual),
      ]);

      _vendas = results[0] as List<Venda>;
      _despesas = results[1] as List<Despesa>;
      _cardapio = results[2] as List<ProdutoCardapio>;
      _categorias = results[3] as List<CategoriaDespesa>;
      _recorrentes = results[4] as List<DespesaRecorrente>;
      _registrosRecorrentes = results[5] as List<RegistroRecorrente>;
      _funcionarios = results[6] as List<Funcionario>;
      _pagamentos = results[7] as List<PagamentoFuncionario>;
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // ── Utilitário ────────────────────────────────────────────────────────────
  String _competenciaAtual() {
    final agora = DateTime.now();
    return '${agora.year}-${agora.month.toString().padLeft(2, '0')}';
  }

  // Recorrentes pendentes no mês atual
  List<DespesaRecorrente> get recorrentesPendentes {
    final competencia = _competenciaAtual();
    final pagoIds = _registrosRecorrentes
        .where((r) => r.competencia == competencia)
        .map((r) => r.despesaRecorrenteId)
        .toSet();
    return _recorrentes
        .where((r) => r.ativo && !pagoIds.contains(r.id))
        .toList();
  }

  // ── Cardápio ──────────────────────────────────────────────────────────────
  Future<void> adicionarProduto(ProdutoCardapio produto) async {
    final novo = await _cardapioRepo.adicionarProduto(produto);
    _cardapio.add(novo);
    notifyListeners();
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

  // ── Categorias ────────────────────────────────────────────────────────────
  Future<void> adicionarCategoria(CategoriaDespesa categoria) async {
    final nova = await _categoriaRepo.adicionarCategoria(categoria);
    _categorias.add(nova);
    notifyListeners();
  }

  Future<void> editarCategoria(CategoriaDespesa categoria) async {
    await _categoriaRepo.atualizarCategoria(categoria);
    final index = _categorias.indexWhere((c) => c.id == categoria.id);
    if (index != -1) {
      _categorias[index] = categoria;
      notifyListeners();
    }
  }

  Future<void> deletarCategoria(String id) async {
    await _categoriaRepo.deletarCategoria(id);
    _categorias.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ── Recorrentes ───────────────────────────────────────────────────────────
  Future<void> adicionarRecorrente(DespesaRecorrente despesa) async {
    final nova = await _recorrenteRepo.adicionarRecorrente(despesa);
    _recorrentes.add(nova);
    notifyListeners();
  }

  Future<void> editarRecorrente(DespesaRecorrente despesa) async {
    await _recorrenteRepo.atualizarRecorrente(despesa);
    final index = _recorrentes.indexWhere((r) => r.id == despesa.id);
    if (index != -1) {
      _recorrentes[index] = despesa;
      notifyListeners();
    }
  }

  Future<void> deletarRecorrente(String id) async {
    await _recorrenteRepo.deletarRecorrente(id);
    _recorrentes.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> registrarPagamentoRecorrente(RegistroRecorrente registro) async {
    final novo = await _recorrenteRepo.registrarPagamento(registro);
    _registrosRecorrentes.add(novo);
    notifyListeners();
  }

  // ── Funcionários ──────────────────────────────────────────────────────────
  Future<void> adicionarFuncionario(Funcionario funcionario) async {
    final novo = await _funcionarioRepo.adicionarFuncionario(funcionario);
    _funcionarios.add(novo);
    notifyListeners();
  }

  Future<void> editarFuncionario(Funcionario funcionario) async {
    await _funcionarioRepo.atualizarFuncionario(funcionario);
    final index = _funcionarios.indexWhere((f) => f.id == funcionario.id);
    if (index != -1) {
      _funcionarios[index] = funcionario;
      notifyListeners();
    }
  }

  Future<void> deletarFuncionario(String id) async {
    await _funcionarioRepo.deletarFuncionario(id);
    _funcionarios.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  Future<void> adicionarPagamentoFuncionario(PagamentoFuncionario pagamento) async {
    final novo = await _funcionarioRepo.adicionarPagamento(pagamento);
    _pagamentos.add(novo);
    notifyListeners();
  }

  Future<void> atualizarPagamentoFuncionario(PagamentoFuncionario pagamento) async {
    await _funcionarioRepo.atualizarPagamento(pagamento);
    final index = _pagamentos.indexWhere((p) => p.id == pagamento.id);
    if (index != -1) {
      _pagamentos[index] = pagamento;
      notifyListeners();
    }
  }

  Future<void> deletarPagamentoFuncionario(String id) async {
    await _funcionarioRepo.deletarPagamento(id);
    _pagamentos.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}