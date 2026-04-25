class Venda {
  final String id;
  final String produtoId;
  final String nomeProdutoSnapshot;
  final String categoriaSnapshot;
  final double precoUnitarioSnapshot;
  final int quantidade;
  final DateTime data;

  const Venda({
    required this.id,
    required this.produtoId,
    required this.nomeProdutoSnapshot,
    required this.categoriaSnapshot,
    required this.precoUnitarioSnapshot,
    required this.quantidade,
    required this.data,
  });

  // Valor total desta venda (preço × quantidade)
  double get valorTotal => precoUnitarioSnapshot * quantidade;

  @override
  String toString() =>
      'Venda(produto: $nomeProdutoSnapshot, quantidade: $quantidade, total: $valorTotal, data: $data)';
}