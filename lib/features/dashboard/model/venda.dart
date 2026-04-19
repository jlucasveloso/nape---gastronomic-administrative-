class Venda {
  final String id;
  final String produto;
  final String categoria;
  final double valorUnitario;
  final int quantidade;
  final DateTime data;
  final String? observacao;

  const Venda({
    required this.id,
    required this.produto,
    required this.categoria,
    required this.valorUnitario,
    required this.quantidade,
    required this.data,
    this.observacao,
  });

  double get valorTotal => valorUnitario * quantidade;

  @override
  String toString() =>
      'Venda(produto: $produto, quantidade: $quantidade, total: $valorTotal, data: $data)';
}