import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TempAuth {
  static final ValueNotifier<bool> logado = ValueNotifier(false);

  static final Map<String, Map<String, dynamic>> _usuarios = {};

  static String? _emailAtual;

  static String? get emailAtual => _emailAtual;

  static String? get nomeRestaurante =>
      _emailAtual == null ? null : _usuarios[_emailAtual]?['nomeRestaurante'];

  static String? get telefone =>
      _emailAtual == null ? null : _usuarios[_emailAtual]?['telefone'];

  static String? get cnpj =>
      _emailAtual == null ? null : _usuarios[_emailAtual]?['cnpj'];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('usuarios_local');

    if (dados != null) {
      final decoded = jsonDecode(dados) as Map<String, dynamic>;

      _usuarios.clear();

      decoded.forEach((email, usuario) {
        _usuarios[email] = Map<String, dynamic>.from(usuario);
      });
    }

    _emailAtual = prefs.getString('email_atual');
    logado.value = _emailAtual != null && _usuarios.containsKey(_emailAtual);
  }

  static Future<void> cadastrar({
    required String novoEmail,
    required String novaSenha,
    required String novoNomeRestaurante,
    required String novoTelefone,
    String? novoCnpj,
  }) async {
    _usuarios[novoEmail] = {
      'email': novoEmail,
      'senha': novaSenha,
      'nomeRestaurante': novoNomeRestaurante,
      'telefone': novoTelefone,
      'cnpj': novoCnpj,
    };

    await _salvarUsuarios();
  }

  static bool login(String email, String senha) {
    final usuario = _usuarios[email];

    final sucesso = usuario != null && usuario['senha'] == senha;

    if (sucesso) {
      _emailAtual = email;
      logado.value = true;
      _salvarSessao();
    }

    return sucesso;
  }

  static Future<void> logout() async {
    _emailAtual = null;
    logado.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email_atual');
  }

  static Future<void> _salvarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuarios_local', jsonEncode(_usuarios));
  }

  static Future<void> _salvarSessao() async {
    final prefs = await SharedPreferences.getInstance();

    if (_emailAtual != null) {
      await prefs.setString('email_atual', _emailAtual!);
    }
  }
}