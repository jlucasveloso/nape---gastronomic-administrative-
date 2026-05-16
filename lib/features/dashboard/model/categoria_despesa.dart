class CategoriaDespesa {
  final String id;
  final String userId;
  final String nome;
  final String tipo; // ingredientes | mao_de_obra | fixo | operacional | outros
  final DateTime createdAt;

  const CategoriaDespesa({
    required this.id,
    required this.userId,
    required this.nome,
    required this.tipo,
    required this.createdAt,
  });

  factory CategoriaDespesa.fromMap(Map<String, dynamic> map) {
    return CategoriaDespesa(
      id: map['id'],
      userId: map['user_id'],
      nome: map['nome'],
      tipo: map['tipo'] ?? 'outros',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo,
    };
  }
}