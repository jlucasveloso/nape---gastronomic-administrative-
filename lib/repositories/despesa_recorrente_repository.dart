import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proj_nape/features/dashboard/model/despesa_recorrente.dart';
import 'package:proj_nape/features/dashboard/model/registro_recorrente.dart';

class DespesaRecorrenteRepository {
  final _supabase = Supabase.instance.client;

  String _resolverUserId(String? userId) {
    return userId ?? _supabase.auth.currentUser!.id;
  }

  // ── Despesas recorrentes ──────────────────────────────────────────────────

  Future<List<DespesaRecorrente>> buscarRecorrentes({String? userId}) async {
    final id = _resolverUserId(userId);

    final data = await _supabase
        .from('despesas_recorrentes')
        .select()
        .eq('user_id', id)
        .order('descricao', ascending: true);

    return data.map((map) => DespesaRecorrente.fromMap(map)).toList();
  }

  Future<DespesaRecorrente> adicionarRecorrente(
    DespesaRecorrente despesa, {
    String? userId,
  }) async {
    final id = _resolverUserId(userId);

    final data = await _supabase.from('despesas_recorrentes').insert({
      'user_id': id,
      ...despesa.toMap(),
    }).select().single();

    return DespesaRecorrente.fromMap(data);
  }

  Future<void> atualizarRecorrente(DespesaRecorrente despesa) async {
    await _supabase
        .from('despesas_recorrentes')
        .update(despesa.toMap())
        .eq('id', despesa.id);
  }

  Future<void> deletarRecorrente(String id) async {
    await _supabase.from('despesas_recorrentes').delete().eq('id', id);
  }

  // ── Registros de recorrentes ──────────────────────────────────────────────

  Future<List<RegistroRecorrente>> buscarRegistros({
    String? userId,
    String? competencia,
  }) async {
    final id = _resolverUserId(userId);

    var query = _supabase
        .from('registros_recorrentes')
        .select()
        .eq('user_id', id);

    if (competencia != null) {
      query = query.eq('competencia', competencia);
    }

    final data = await query.order('registrado_em', ascending: false);
    return data.map((map) => RegistroRecorrente.fromMap(map)).toList();
  }

  Future<RegistroRecorrente> registrarPagamento(
    RegistroRecorrente registro, {
    String? userId,
  }) async {
    final id = _resolverUserId(userId);

    final data = await _supabase.from('registros_recorrentes').insert({
      'user_id': id,
      ...registro.toMap(),
    }).select().single();

    return RegistroRecorrente.fromMap(data);
  }

  Future<void> deletarRegistro(String id) async {
    await _supabase.from('registros_recorrentes').delete().eq('id', id);
  }

  // ── Utilitário: recorrentes pendentes no mês ──────────────────────────────

  Future<List<DespesaRecorrente>> buscarPendentes({
    required String competencia,
    String? userId,
  }) async {
    final id = _resolverUserId(userId);

    // Busca todas as recorrentes ativas
    final recorrentes = await buscarRecorrentes(userId: id);
    final ativas = recorrentes.where((r) => r.ativo).toList();

    // Busca registros já pagos nessa competência
    final registros = await buscarRegistros(userId: id, competencia: competencia);
    final pagoIds = registros.map((r) => r.despesaRecorrenteId).toSet();

    // Retorna as que ainda não foram pagas
    return ativas.where((r) => !pagoIds.contains(r.id)).toList();
  }
}