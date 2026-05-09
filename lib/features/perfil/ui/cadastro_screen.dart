import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:proj_nape/shared/temp_auth.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cnpjController = TextEditingController();

  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool _temMaiuscula = false;
  bool _temNumero = false;
  bool _temEspecial = false;
  bool _tem8Caracteres = false;
  bool _mostrarSenha = false;

  bool _carregando = false;
  String? _erro;

  void _validarSenha(String senha) {
    setState(() {
      _temMaiuscula = senha.contains(RegExp(r'[A-Z]'));
      _temNumero = senha.contains(RegExp(r'[0-9]'));
      _temEspecial = senha.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _tem8Caracteres = senha.length >= 8;
    });
  }

  Future<void> _criarConta() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    final telefone = _telefoneController.text.trim();
    final cnpj = _cnpjController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || telefone.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos obrigatórios.');
      return;
    }

    if (!_temMaiuscula || !_temNumero || !_temEspecial || !_tem8Caracteres) {
      setState(() {
        _erro =
            'A senha deve conter letra maiúscula, número, caractere especial e mínimo de 8 caracteres.';
      });
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    TempAuth.cadastrar(
      novoEmail: email,
      novaSenha: senha,
      novoNomeRestaurante: nome,
      novoTelefone: telefone,
      novoCnpj: cnpj.isEmpty ? null : cnpj,
    );

    if (mounted) {
      setState(() => _carregando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso! Agora faça login.'),
          backgroundColor: Color(0xFFC2463C),
        ),
      );

      Navigator.pop(context);
    }
  }

  Widget _requisito(String texto, bool valido) {
    return Row(
      children: [
        Icon(
          valido ? Icons.check_circle : Icons.cancel,
          color: valido ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            color: valido ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE9E4DF),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Napê',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC2463C),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _label('Nome do restaurante *'),
                _input('Ex: Restaurante do João', _nomeController),

                const SizedBox(height: 12),

                _label('Email *'),
                _input(
                  'seu@email.com',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 12),

                _label('Senha *'),
                _input(
                  'Digite sua senha',
                  _senhaController,
                  obscure: !_mostrarSenha,
                  onChanged: _validarSenha,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarSenha
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _mostrarSenha = !_mostrarSenha;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 8),

                _requisito('Mínimo 8 caracteres', _tem8Caracteres),
                _requisito('Uma letra maiúscula', _temMaiuscula),
                _requisito('Um número', _temNumero),
                _requisito('Um caractere especial', _temEspecial),

                const SizedBox(height: 12),

                _label('Telefone *'),
                _input(
                  '(11) 99999-9999',
                  _telefoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_telefoneMask],
                ),

                const SizedBox(height: 12),

                _label('CNPJ (opcional)'),
                _input(
                  '00.000.000/0000-00',
                  _cnpjController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cnpjMask],
                ),

                const SizedBox(height: 12),

                if (_erro != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _erro!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2463C),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _carregando ? null : _criarConta,
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Criar conta',
                          style: TextStyle(color: Colors.white),
                        ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Já tem conta? ',
                        style: TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'Entrar',
                            style: TextStyle(color: Color(0xFFC2463C)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _input(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}