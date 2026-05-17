import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoMonetario extends StatefulWidget {
  final String label;
  final double? valorInicial;
  final void Function(double valor) onChanged;
  final InputDecoration? decoration;

  const CampoMonetario({
    super.key,
    required this.label,
    required this.onChanged,
    this.valorInicial,
    this.decoration,
  });

  @override
  State<CampoMonetario> createState() => _CampoMonetarioState();
}

class _CampoMonetarioState extends State<CampoMonetario> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final inicial = widget.valorInicial ?? 0.0;
    final centavos = (inicial * 100).round();
    _controller = TextEditingController(text: _formatar(centavos));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatar(int centavos) {
    final reais = centavos ~/ 100;
    final cents = centavos % 100;
    if (reais >= 1000) {
      final milhar = reais ~/ 1000;
      final resto = reais % 1000;
      return 'R\$ $milhar.${resto.toString().padLeft(3, '0')},${cents.toString().padLeft(2, '0')}';
    }
    return 'R\$ $reais,${cents.toString().padLeft(2, '0')}';
  }

  void _onInput(String value) {
    final soDigitos = value.replaceAll(RegExp(r'\D'), '');
    final centavos = int.tryParse(soDigitos) ?? 0;
    final formatado = _formatar(centavos);

    _controller.value = TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(offset: formatado.length),
    );

    widget.onChanged(centavos / 100.0);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: _onInput,
      decoration: widget.decoration ??
          InputDecoration(
            labelText: widget.label,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            labelStyle:
                const TextStyle(fontSize: 13, color: Colors.black45),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFFC2463C), width: 1.5),
            ),
          ),
    );
  }
}