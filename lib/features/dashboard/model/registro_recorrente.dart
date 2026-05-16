class RegistroRecorrente {
  final String id;
  final String despesaRecorrenteId;
  final String userId;
  final double valor;
  final String competencia; // ex: "2026-05"
  final DateTime registradoEm;
  final String? observacao;

  const RegistroRecorrente({
    required this.id,
    required this.despesaRecorrenteId,
    required this.userId,
    required this.valor,
    required this.competencia,
    required this.registradoEm,
    this.observacao,
  });

  factory RegistroRecorrente.fromMap(Map<String, dynamic> map) {
    return RegistroRecorrente(
      id: map['id'],
      despesaRecorrenteId: map['despesa_recorrente_id'],
      userId: map['user_id'],
      valor: (map['valor'] as num).toDouble(),
      competencia: map['competencia'],
      registradoEm: DateTime.parse(map['registrado_em']),
      observacao: map['observacao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'despesa_recorrente_id': despesaRecorrenteId,
      'valor': valor,
      'competencia': competencia,
      'observacao': observacao,
    };
  }
}