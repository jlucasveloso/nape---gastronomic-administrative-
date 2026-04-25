class ProdutoCardapio {
  final String id;
  final String nome;
  final String categoria;
  final double preco;
  final bool ativo;
  final DateTime dataCadastro;

  const ProdutoCardapio({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.preco,
    this.ativo = true,
    required this.dataCadastro,
  });

  @override
  String toString() =>
      'ProdutoCardapio(nome: $nome, categoria: $categoria, preco: $preco, ativo: $ativo, dataCadastro: $dataCadastro)';
}