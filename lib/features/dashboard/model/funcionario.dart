class Funcionario {
  final String id;
  final String userId;
  final String nome;
  final String cargo;
  final double salarioBase;
  final DateTime dataAdmissao;
  final String status; // ativo | demitido | afastado
  final DateTime? dataDemissao;
  final DateTime createdAt;

  const Funcionario({
    required this.id,
    required this.userId,
    required this.nome,
    required this.cargo,
    required this.salarioBase,
    required this.dataAdmissao,
    this.status = 'ativo',
    this.dataDemissao,
    required this.createdAt,
  });

  factory Funcionario.fromMap(Map<String, dynamic> map) {
    return Funcionario(
      id: map['id'],
      userId: map['user_id'],
      nome: map['nome'],
      cargo: map['cargo'],
      salarioBase: (map['salario_base'] as num).toDouble(),
      dataAdmissao: DateTime.parse(map['data_admissao']),
      status: map['status'] ?? 'ativo',
      dataDemissao: map['data_demissao'] != null
          ? DateTime.parse(map['data_demissao'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cargo': cargo,
      'salario_base': salarioBase,
      'data_admissao': dataAdmissao.toIso8601String(),
      'status': status,
      'data_demissao': dataDemissao?.toIso8601String(),
    };
  }
}