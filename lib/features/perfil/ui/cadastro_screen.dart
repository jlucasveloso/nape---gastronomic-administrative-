import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

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

  final _nomeFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _senhaFocus = FocusNode();
  final _telefoneFocus = FocusNode();
  final _cnpjFocus = FocusNode();

  String? _erroNome;
  String? _erroEmail;
  String? _erroSenha;
  String? _erroTelefone;
  String? _erroCnpj;
  String? _erroGeral;

  bool _carregando = false;
  bool _senhaVisivel = false;

  @override
  void initState() {
    super.initState();
    _nomeFocus.addListener(() {
      if (!_nomeFocus.hasFocus) _validarNome();
    });
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _validarEmail();
    });
    _senhaFocus.addListener(() {
      if (!_senhaFocus.hasFocus) _validarSenha();
    });
    _telefoneFocus.addListener(() {
      if (!_telefoneFocus.hasFocus) _validarTelefone();
    });
    _cnpjFocus.addListener(() {
      if (!_cnpjFocus.hasFocus) _validarCnpj();
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _cnpjController.dispose();
    _nomeFocus.dispose();
    _emailFocus.dispose();
    _senhaFocus.dispose();
    _telefoneFocus.dispose();
    _cnpjFocus.dispose();
    super.dispose();
  }

  // ── Validações ─────────────────────────────────────────────────────────────

  String? _validarNome() {
    final v = _nomeController.text.trim();
    String? erro;
    if (v.isEmpty) {
      erro = 'Nome do restaurante é obrigatório';
    } else if (v.length < 3) {
      erro = 'Mínimo 3 caracteres';
    }
    setState(() => _erroNome = erro);
    return erro;
  }

  String? _validarEmail() {
    final v = _emailController.text.trim();
    String? erro;
    if (v.isEmpty) {
      erro = 'Email é obrigatório';
    } else if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(v)) {
      erro = 'Email inválido';
    }
    setState(() => _erroEmail = erro);
    return erro;
  }

  String? _validarSenha() {
    final v = _senhaController.text;
    String? erro;
    if (v.isEmpty) {
      erro = 'Senha é obrigatória';
    } else if (v.length < 8) {
      erro = 'Mínimo 8 caracteres';
    } else if (!RegExp(r'[A-Z]').hasMatch(v)) {
      erro = 'Inclua ao menos uma letra maiúscula';
    } else if (!RegExp(r'[0-9]').hasMatch(v)) {
      erro = 'Inclua ao menos um número';
    }
    setState(() => _erroSenha = erro);
    return erro;
  }

  String? _validarTelefone() {
    final v = _telefoneController.text.replaceAll(RegExp(r'\D'), '');
    String? erro;
    if (v.isEmpty) {
      erro = 'Telefone é obrigatório';
    } else if (v.length < 10 || v.length > 11) {
      erro = 'Telefone inválido — use DDD + número';
    }
    setState(() => _erroTelefone = erro);
    return erro;
  }

  String? _validarCnpj() {
    final v = _cnpjController.text.replaceAll(RegExp(r'\D'), '');
    if (v.isEmpty) {
      setState(() => _erroCnpj = null);
      return null;
    }
    String? erro;
    if (v.length != 14) {
      erro = 'CNPJ deve ter 14 dígitos';
    } else if (!_cnpjValido(v)) {
      erro = 'CNPJ inválido';
    }
    setState(() => _erroCnpj = erro);
    return erro;
  }

  bool _cnpjValido(String cnpj) {
    if (RegExp(r'^(\d)\1+$').hasMatch(cnpj)) return false;

    const pesos1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int soma = 0;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(cnpj[i]) * pesos1[i];
    }
    int dig1 = soma % 11 < 2 ? 0 : 11 - (soma % 11);

    const pesos2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    soma = 0;
    for (int i = 0; i < 13; i++) {
      soma += int.parse(cnpj[i]) * pesos2[i];
    }
    int dig2 = soma % 11 < 2 ? 0 : 11 - (soma % 11);

    return int.parse(cnpj[12]) == dig1 && int.parse(cnpj[13]) == dig2;
  }

  bool _validarTudo() {
    final erros = [
      _validarNome(),
      _validarEmail(),
      _validarSenha(),
      _validarTelefone(),
      _validarCnpj(),
    ];
    return erros.every((e) => e == null);
  }

  // ── Formatação automática ──────────────────────────────────────────────────

  String _formatarTelefone(String v) {
    v = v.replaceAll(RegExp(r'\D'), '');
    if (v.length > 11) v = v.substring(0, 11);
    if (v.length <= 10) {
      v = v.replaceFirstMapped(
          RegExp(r'^(\d{2})(\d{4})(\d{0,4})$'),
          (m) => '(${m[1]}) ${m[2]}${m[3]!.isNotEmpty ? '-${m[3]}' : ''}');
    } else {
      v = v.replaceFirstMapped(
          RegExp(r'^(\d{2})(\d{5})(\d{0,4})$'),
          (m) => '(${m[1]}) ${m[2]}${m[3]!.isNotEmpty ? '-${m[3]}' : ''}');
    }
    return v;
  }

  String _formatarCnpj(String v) {
    v = v.replaceAll(RegExp(r'\D'), '');
    if (v.length > 14) v = v.substring(0, 14);
    v = v.replaceFirstMapped(
        RegExp(r'^(\d{2})(\d{3})(\d{3})(\d{4})(\d{0,2})$'),
        (m) =>
            '${m[1]}.${m[2]}.${m[3]}/${m[4]}${m[5]!.isNotEmpty ? '-${m[5]}' : ''}');
    return v;
  }

  // ── Criar conta ────────────────────────────────────────────────────────────

  Future<void> _criarConta() async {
  if (!_validarTudo()) return;

  setState(() {
    _carregando = true;
    _erroGeral = null;
  });

  try {
    final response = await supabase.auth.signUp(
      email: _emailController.text.trim(),
      password: _senhaController.text,
    );

    final user = response.user;
    if (user == null) throw Exception('Erro ao criar conta.');

    final cnpj = _cnpjController.text.replaceAll(RegExp(r'\D'), '');

    await supabase.from('perfis').insert({
      'id': user.id,
      'nome_restaurante': _nomeController.text.trim(),
      'telefone': _telefoneController.text.trim(),
      'cnpj': cnpj.isEmpty ? null : cnpj,
    });

    if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Bem-vindo ao Napê!'),
      backgroundColor: Color(0xFF3E8E41),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
  } on AuthException catch (e) {
    setState(() => _erroGeral = _traduzirErroAuth(e.message));
  } catch (e) {
    setState(() => _erroGeral = 'Erro inesperado. Tente novamente.');
  } finally {
    if (mounted) setState(() => _carregando = false);
  }
}

  String _traduzirErroAuth(String mensagem) {
  final m = mensagem.toLowerCase();
  if (m.contains('already registered') || m.contains('user already exists')) {
    return 'Este email já está cadastrado.';
  }
  if (m.contains('invalid email')) return 'Email inválido.';
  if (m.contains('weak password')) return 'Senha muito fraca.';
  if (m.contains('email not confirmed')) return 'Confirme seu email antes de entrar.';
  if (m.contains('network') || m.contains('connection')) {
    return 'Erro de conexão. Verifique sua internet.';
  }
  // Mostra a mensagem original em desenvolvimento para identificar novos casos
  debugPrint('Erro Auth não mapeado: $mensagem');
  return 'Erro ao criar conta. Tente novamente.';
}

  // ── Força da senha ─────────────────────────────────────────────────────────

  int _forcaSenha(String senha) {
    int forca = 0;
    if (senha.length >= 8) forca++;
    if (RegExp(r'[A-Z]').hasMatch(senha)) forca++;
    if (RegExp(r'[0-9]').hasMatch(senha)) forca++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(senha)) forca++;
    return forca;
  }

  @override
  Widget build(BuildContext context) {
    final senha = _senhaController.text;
    final forca = _forcaSenha(senha);

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
              mainAxisSize: MainAxisSize.min,
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
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Nome ─────────────────────────────────────────────────
                _Campo(
                  label: 'Nome do restaurante *',
                  hint: 'Ex: Restaurante do João',
                  controller: _nomeController,
                  focusNode: _nomeFocus,
                  erro: _erroNome,
                  maxLength: 60,
                  formatters: [
                    LengthLimitingTextInputFormatter(60),
                  ],
                  onChanged: (_) {
                    if (_erroNome != null) _validarNome();
                  },
                ),
                const SizedBox(height: 12),

                // ── Email ─────────────────────────────────────────────────
                _Campo(
                  label: 'Email *',
                  hint: 'seu@email.com',
                  controller: _emailController,
                  focusNode: _emailFocus,
                  erro: _erroEmail,
                  teclado: TextInputType.emailAddress,
                  formatters: [
                    LengthLimitingTextInputFormatter(100),
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  onChanged: (_) {
                    if (_erroEmail != null) _validarEmail();
                  },
                ),
                const SizedBox(height: 12),

                // ── Senha ─────────────────────────────────────────────────
                _Campo(
                  label: 'Senha *',
                  hint: 'Mínimo 8 caracteres',
                  controller: _senhaController,
                  focusNode: _senhaFocus,
                  erro: _erroSenha,
                  obscure: !_senhaVisivel,
                  formatters: [
                    LengthLimitingTextInputFormatter(32),
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  sufixo: IconButton(
                    icon: Icon(
                      _senhaVisivel
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: Colors.black38,
                    ),
                    onPressed: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                  onChanged: (_) {
                    setState(() {});
                    if (_erroSenha != null) _validarSenha();
                  },
                ),

                // Indicador de força
                if (senha.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(4, (i) {
                      final Color cor = i < forca
                          ? (forca <= 1
                              ? const Color(0xFFC2463C)
                              : forca == 2
                                  ? const Color(0xFFFFB300)
                                  : forca == 3
                                      ? const Color(0xFF2D74C4)
                                      : const Color(0xFF3E8E41))
                          : Colors.grey.shade300;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                          height: 3,
                          decoration: BoxDecoration(
                            color: cor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    forca == 1
                        ? 'Senha fraca'
                        : forca == 2
                            ? 'Senha razoável'
                            : forca == 3
                                ? 'Senha boa'
                                : forca == 4
                                    ? 'Senha forte'
                                    : '',
                    style: TextStyle(
                      fontSize: 11,
                      color: forca <= 1
                          ? const Color(0xFFC2463C)
                          : forca == 2
                              ? const Color(0xFFFFB300)
                              : forca == 3
                                  ? const Color(0xFF2D74C4)
                                  : const Color(0xFF3E8E41),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ── Telefone ──────────────────────────────────────────────
                _Campo(
                  label: 'Telefone *',
                  hint: '(11) 99999-9999',
                  controller: _telefoneController,
                  focusNode: _telefoneFocus,
                  erro: _erroTelefone,
                  teclado: TextInputType.phone,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  onChanged: (v) {
                    final formatado = _formatarTelefone(v);
                    if (formatado != v) {
                      _telefoneController.value = TextEditingValue(
                        text: formatado,
                        selection: TextSelection.collapsed(
                            offset: formatado.length),
                      );
                    }
                    if (_erroTelefone != null) _validarTelefone();
                  },
                ),
                const SizedBox(height: 12),

                // ── CNPJ ──────────────────────────────────────────────────
                _Campo(
                  label: 'CNPJ (opcional)',
                  hint: '00.000.000/0000-00',
                  controller: _cnpjController,
                  focusNode: _cnpjFocus,
                  erro: _erroCnpj,
                  teclado: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(14),
                  ],
                  onChanged: (v) {
                    final formatado = _formatarCnpj(v);
                    if (formatado != v) {
                      _cnpjController.value = TextEditingValue(
                        text: formatado,
                        selection: TextSelection.collapsed(
                            offset: formatado.length),
                      );
                    }
                    if (_erroCnpj != null) _validarCnpj();
                  },
                ),
                const SizedBox(height: 8),

                // ── Erro geral ────────────────────────────────────────────
                if (_erroGeral != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC2463C).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color:
                                const Color(0xFFC2463C).withOpacity(0.3)),
                      ),
                      child: Text(
                        _erroGeral!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFC2463C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // ── Botão criar conta ─────────────────────────────────────
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
                      : const Text('Criar conta',
                          style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 12),

                // ── Voltar para login ─────────────────────────────────────
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget campo com erro ─────────────────────────────────────────────────────

class _Campo extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? erro;
  final bool obscure;
  final TextInputType? teclado;
  final void Function(String)? onChanged;
  final Widget? sufixo;
  final int? maxLength;
  final List<TextInputFormatter>? formatters;

  const _Campo({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.erro,
    this.obscure = false,
    this.teclado,
    this.onChanged,
    this.sufixo,
    this.maxLength,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    final temErro = erro != null;
    final temConteudo = controller.text.isNotEmpty;
    final valido = temConteudo && !temErro;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          keyboardType: teclado,
          onChanged: onChanged,
          maxLength: maxLength,
          inputFormatters: formatters,
          buildCounter: maxLength != null
              ? (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  Text(
                    '$currentLength/${maxLength!}',
                    style: TextStyle(
                      fontSize: 11,
                      color: currentLength > maxLength * 0.9
                          ? const Color(0xFFC2463C)
                          : Colors.black38,
                    ),
                  )
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 13, color: Colors.black38),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: sufixo ??
                (valido
                    ? const Icon(Icons.check_circle_outline,
                        size: 18, color: Color(0xFF3E8E41))
                    : null),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: temErro
                  ? const BorderSide(color: Color(0xFFC2463C), width: 1.5)
                  : valido
                      ? const BorderSide(
                          color: Color(0xFF3E8E41), width: 1.5)
                      : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: temErro
                  ? const BorderSide(color: Color(0xFFC2463C), width: 1.5)
                  : const BorderSide(
                      color: Color(0xFFC2463C), width: 1.5),
            ),
          ),
        ),
        if (temErro) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  size: 13, color: Color(0xFFC2463C)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  erro!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFC2463C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}