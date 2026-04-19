class Despesa {
  final String id;
  final String descricao;
  final String categoria;
  final double valor;
  final DateTime data;
  final String? observacao;

  const Despesa({
    required this.id,
    required this.descricao,
    required this.categoria,
    required this.valor,
    required this.data,
    this.observacao,
  });

  @override
  String toString() =>
      'Despesa(descricao: $descricao, categoria: $categoria, valor: $valor, data: $data)';
}