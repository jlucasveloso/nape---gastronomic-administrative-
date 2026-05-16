class DespesaRecorrente {
  final String id;
  final String userId;
  final String descricao;
  final String? categoriaId;
  final double valorReferencia;
  final int diaVencimento;
  final bool ativo;
  final DateTime createdAt;

  const DespesaRecorrente({
    required this.id,
    required this.userId,
    required this.descricao,
    this.categoriaId,
    required this.valorReferencia,
    required this.diaVencimento,
    this.ativo = true,
    required this.createdAt,
  });

  factory DespesaRecorrente.fromMap(Map<String, dynamic> map) {
    return DespesaRecorrente(
      id: map['id'],
      userId: map['user_id'],
      descricao: map['descricao'],
      categoriaId: map['categoria_id'],
      valorReferencia: (map['valor_referencia'] as num).toDouble(),
      diaVencimento: map['dia_vencimento'],
      ativo: map['ativo'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'categoria_id': categoriaId,
      'valor_referencia': valorReferencia,
      'dia_vencimento': diaVencimento,
      'ativo': ativo,
    };
  }
}