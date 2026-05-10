import 'package:flutter/material.dart';

class AdminCardsResumo extends StatelessWidget {
  final String faturamento;
  final String custos;
  final String lucro;
  final bool emPrejuizo;

  const AdminCardsResumo({
    super.key,
    required this.faturamento,
    required this.custos,
    required this.lucro,
    required this.emPrejuizo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Card(
            titulo: 'Faturamento',
            valor: faturamento,
            cor: const Color(0xFF2D74C4),
          ),
          const SizedBox(width: 8),
          _Card(
            titulo: 'Custos',
            valor: custos,
            cor: const Color(0xFFC2463C),
          ),
          const SizedBox(width: 8),
          _Card(
            titulo: emPrejuizo ? 'Prejuízo' : 'Lucro',
            valor: lucro,
            cor: emPrejuizo
                ? const Color(0xFFC2463C)
                : const Color(0xFF3E8E41),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color cor;

  const _Card({
    required this.titulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black38,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}