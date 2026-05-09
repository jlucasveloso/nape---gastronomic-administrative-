import 'package:flutter/material.dart';

class TempAuth {
  static final ValueNotifier<bool> logado =
      ValueNotifier(false);

  static String? _email;
  static String? _senha;
  static String? nomeRestaurante;
  static String? telefone;
  static String? cnpj;

  static void cadastrar({
    required String novoEmail,
    required String novaSenha,
    required String novoNomeRestaurante,
    required String novoTelefone,
    String? novoCnpj,
  }) {
    _email = novoEmail;
    _senha = novaSenha;
    nomeRestaurante = novoNomeRestaurante;
    telefone = novoTelefone;
    cnpj = novoCnpj;
  }

  static bool login(
    String email,
    String senha,
  ) {
    final sucesso =
        email == _email && senha == _senha;

    logado.value = sucesso;

    return sucesso;
  }

  static void logout() {
    logado.value = false;
  }
}