class DespesaNormal {
  final String id;
  final String nome;
  final String categoria;
  final double valor;
  final DateTime data;
  final String formaPagamento;
  final String observacao;

  DespesaNormal({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.valor,
    required this.data,
    this.formaPagamento = '',
    this.observacao = '',
  });

  DespesaNormal copyWith({
    String? id,
    String? nome,
    String? categoria,
    double? valor,
    DateTime? data,
    String? formaPagamento,
    String? observacao,
  }) {
    return DespesaNormal(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      formaPagamento:
          formaPagamento ?? this.formaPagamento,
      observacao: observacao ?? this.observacao,
    );
  }
}