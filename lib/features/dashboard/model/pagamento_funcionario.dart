class PagamentoFuncionario {
  final String id;
  final String funcionarioId;
  final String userId;
  final String tipo; // salario | comissao | bonus | diaria | desconto | ferias | decimo | rescisao
  final double valor;
  final String competencia; // ex: "2026-05"
  final String status; // pendente | pago | cancelado
  final DateTime? dataPagamento;
  final String? observacao;
  final bool geradoAutomaticamente;
  final DateTime createdAt;

  const PagamentoFuncionario({
    required this.id,
    required this.funcionarioId,
    required this.userId,
    required this.tipo,
    required this.valor,
    required this.competencia,
    this.status = 'pendente',
    this.dataPagamento,
    this.observacao,
    this.geradoAutomaticamente = false,
    required this.createdAt,
  });

  factory PagamentoFuncionario.fromMap(Map<String, dynamic> map) {
    return PagamentoFuncionario(
      id: map['id'],
      funcionarioId: map['funcionario_id'],
      userId: map['user_id'],
      tipo: map['tipo'],
      valor: (map['valor'] as num).toDouble(),
      competencia: map['competencia'],
      status: map['status'] ?? 'pendente',
      dataPagamento: map['data_pagamento'] != null
          ? DateTime.parse(map['data_pagamento'])
          : null,
      observacao: map['observacao'],
      geradoAutomaticamente: map['gerado_automaticamente'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'valor': valor,
      'competencia': competencia,
      'status': status,
      'data_pagamento': dataPagamento?.toIso8601String(),
      'observacao': observacao,
      'gerado_automaticamente': geradoAutomaticamente,
    };
  }
}