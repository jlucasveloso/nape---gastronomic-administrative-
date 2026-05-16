class FuncionarioMes {
  final String id;
  final String nome;
  final String cargo;
  final double salarioBase;
  final double horaExtra;
  final double comissao;
  final double descontos;
  final String observacao;

  FuncionarioMes({
    required this.id,
    required this.nome,
    required this.cargo,
    required this.salarioBase,
    this.horaExtra = 0,
    this.comissao = 0,
    this.descontos = 0,
    this.observacao = '',
  });

  double get total {
    return salarioBase + horaExtra + comissao - descontos;
  }

  FuncionarioMes copyWith({
    String? id,
    String? nome,
    String? cargo,
    double? salarioBase,
    double? horaExtra,
    double? comissao,
    double? descontos,
    String? observacao,
  }) {
    return FuncionarioMes(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cargo: cargo ?? this.cargo,
      salarioBase: salarioBase ?? this.salarioBase,
      horaExtra: horaExtra ?? this.horaExtra,
      comissao: comissao ?? this.comissao,
      descontos: descontos ?? this.descontos,
      observacao: observacao ?? this.observacao,
    );
  }
}