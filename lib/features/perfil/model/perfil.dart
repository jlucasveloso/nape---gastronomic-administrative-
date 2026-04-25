class Perfil {
  final String id;
  final String nomeRestaurante;
  final String telefone;
  final String? cnpj;
  final DateTime createdAt;

  const Perfil({
    required this.id,
    required this.nomeRestaurante,
    required this.telefone,
    this.cnpj,
    required this.createdAt,
  });

  factory Perfil.fromMap(Map<String, dynamic> map) {
    return Perfil(
      id: map['id'],
      nomeRestaurante: map['nome_restaurante'],
      telefone: map['telefone'],
      cnpj: map['cnpj'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome_restaurante': nomeRestaurante,
      'telefone': telefone,
      'cnpj': cnpj,
    };
  }
}