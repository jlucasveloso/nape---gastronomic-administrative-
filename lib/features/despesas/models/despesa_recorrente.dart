class DespesaRecorrente {
  final String id;
  final String nome;
  final String categoria;
  final double valorIdeal;
  final double valorPago;
  final int diaVencimento;
  final DateTime? dataPagamento;
  final String observacao;

  DespesaRecorrente({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.valorIdeal,
    this.valorPago = 0,
    required this.diaVencimento,
    this.dataPagamento,
    this.observacao = '',
  });

  double get diferenca {
    return valorPago - valorIdeal;
  }

  bool get foiPago {
    return valorPago > 0;
  }

  bool get estaAtrasada {
    final hoje = DateTime.now();

    return !foiPago && hoje.day > diaVencimento;
  }

  String get statusAutomatico {
    if (foiPago && diferenca == 0) {
      return 'Pago';
    }

    if (foiPago && diferenca != 0) {
      return 'Pago com diferença';
    }

    if (estaAtrasada) {
      return 'Atrasado';
    }

    return 'Pendente';
  }

  DespesaRecorrente copyWith({
    String? id,
    String? nome,
    String? categoria,
    double? valorIdeal,
    double? valorPago,
    int? diaVencimento,
    DateTime? dataPagamento,
    String? observacao,
  }) {
    return DespesaRecorrente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      valorIdeal: valorIdeal ?? this.valorIdeal,
      valorPago: valorPago ?? this.valorPago,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      observacao: observacao ?? this.observacao,
    );
  }
}