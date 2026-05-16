import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/dashboard/model/funcionario.dart';
import 'package:proj_nape/features/dashboard/model/pagamento_funcionario.dart';

class FuncionarioRepository {
  final _supabase = Supabase.instance.client;

  String _resolverUserId(String? userId) {
    return userId ?? _supabase.auth.currentUser!.id;
  }

  // ── Funcionários ──────────────────────────────────────────────────────────

  Future<List<Funcionario>> buscarFuncionarios({String? userId}) async {
    final id = _resolverUserId(userId);

    final data = await _supabase
        .from('funcionarios')
        .select()
        .eq('user_id', id)
        .order('nome', ascending: true);

    return data.map((map) => Funcionario.fromMap(map)).toList();
  }

  Future<Funcionario> adicionarFuncionario(
    Funcionario funcionario, {
    String? userId,
  }) async {
    final id = _resolverUserId(userId);

    final data = await _supabase.from('funcionarios').insert({
      'user_id': id,
      ...funcionario.toMap(),
    }).select().single();

    return Funcionario.fromMap(data);
  }

  Future<void> atualizarFuncionario(Funcionario funcionario) async {
    await _supabase
        .from('funcionarios')
        .update(funcionario.toMap())
        .eq('id', funcionario.id);
  }

  Future<void> deletarFuncionario(String id) async {
    await _supabase.from('funcionarios').delete().eq('id', id);
  }

  // ── Pagamentos ────────────────────────────────────────────────────────────

  Future<List<PagamentoFuncionario>> buscarPagamentos({
    String? userId,
    String? competencia,
    String? funcionarioId,
  }) async {
    final id = _resolverUserId(userId);

    var query = _supabase
        .from('pagamentos_funcionarios')
        .select()
        .eq('user_id', id);

    if (competencia != null) {
      query = query.eq('competencia', competencia);
    }
    if (funcionarioId != null) {
      query = query.eq('funcionario_id', funcionarioId);
    }

    final data = await query.order('created_at', ascending: false);
    return data.map((map) => PagamentoFuncionario.fromMap(map)).toList();
  }

  Future<PagamentoFuncionario> adicionarPagamento(
    PagamentoFuncionario pagamento, {
    String? userId,
  }) async {
    final id = _resolverUserId(userId);

    final data = await _supabase.from('pagamentos_funcionarios').insert({
      'user_id': id,
      'funcionario_id': pagamento.funcionarioId,
      ...pagamento.toMap(),
    }).select().single();

    return PagamentoFuncionario.fromMap(data);
  }

  Future<void> atualizarPagamento(PagamentoFuncionario pagamento) async {
    await _supabase
        .from('pagamentos_funcionarios')
        .update(pagamento.toMap())
        .eq('id', pagamento.id);
  }

  Future<void> deletarPagamento(String id) async {
    await _supabase.from('pagamentos_funcionarios').delete().eq('id', id);
  }

  // ── Utilitário: gerar salários do mês ────────────────────────────────────

  Future<void> gerarSalariosMes({
    required String competencia,
    String? userId,
  }) async {
    final id = _resolverUserId(userId);

    final funcionarios = await buscarFuncionarios(userId: id);
    final ativos = funcionarios.where((f) => f.status == 'ativo').toList();

    // Verifica quais já têm salário gerado nessa competência
    final pagamentosExistentes = await buscarPagamentos(
      userId: id,
      competencia: competencia,
    );
    final funcionariosComSalario = pagamentosExistentes
        .where((p) => p.tipo == 'salario' && p.geradoAutomaticamente)
        .map((p) => p.funcionarioId)
        .toSet();

    // Gera apenas os que ainda não têm
    for (final funcionario in ativos) {
      if (!funcionariosComSalario.contains(funcionario.id)) {
        await adicionarPagamento(
          PagamentoFuncionario(
            id: '',
            funcionarioId: funcionario.id,
            userId: id,
            tipo: 'salario',
            valor: funcionario.salarioBase,
            competencia: competencia,
            status: 'pendente',
            geradoAutomaticamente: true,
            createdAt: DateTime.now(),
          ),
          userId: id,
        );
      }
    }
  }
}