import 'package:flutter/material.dart';

class TempAuth {
  static String? email;
  static String? senha;
  static String? nomeRestaurante;
  static String? telefone;
  static String? cnpj;

  static final ValueNotifier<bool> logado = ValueNotifier(false);

  static void cadastrar({
    required String novoEmail,
    required String novaSenha,
    required String novoNomeRestaurante,
    required String novoTelefone,
    String? novoCnpj,
  }) {
    email = novoEmail;
    senha = novaSenha;
    nomeRestaurante = novoNomeRestaurante;
    telefone = novoTelefone;
    cnpj = novoCnpj;
  }

  static bool login(String emailDigitado, String senhaDigitada) {
    if (emailDigitado == email && senhaDigitada == senha) {
      logado.value = true;
      return true;
    }

    return false;
  }

  static void sair() {
    logado.value = false;
  }
}