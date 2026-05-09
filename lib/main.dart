import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proj_nape/app_state.dart';
import 'package:proj_nape/main_screen.dart';
import 'package:proj_nape/features/perfil/ui/cadastro_screen.dart';
import 'package:proj_nape/features/admin/ui/admin_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Napê',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF2B2B2B),
        fontFamily: 'Arial',
      ),
      home: const AuthGate(),
    );
  }
}

// ── AuthGate ─────────────────────────────────────────────────────────────────
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) {
            final role =
                supabase.auth.currentUser?.appMetadata['role'] ?? 'usuario';

            if (role == 'admin') {
              return const AdminScreen();
            }

            return MainScreen(key: mainScreenKey);
          }
        }
        return const LoginScreen();
      },
    );
  }
}


// ── LoginScreen ───────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  String? _erro;

  Future<void> _entrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      setState(() => _erro = 'Preencha o email e a senha.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: senha,
      );
    } on AuthException catch (e) {
      setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _criarConta() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      setState(() => _erro = 'Preencha o email e a senha.');
      return;
    }

    if (senha.length < 6) {
      setState(() => _erro = 'A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: senha,
      );
      if (mounted) {
        setState(() =>
            _erro = 'Conta criada! Verifique seu email para confirmar.');
      }
    } on AuthException catch (e) {
      setState(() => _erro = e.message);
    } catch (e) {
      setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE9E4DF),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Napê',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC2463C),
                ),
              ),
              const SizedBox(height: 40),
              _input('Email', _emailController),
              const SizedBox(height: 16),
              _input('Senha', _senhaController, obscure: true),
              const SizedBox(height: 8),

              if (_erro != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _erro!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _erro!.contains('Verifique')
                          ? Colors.green
                          : Colors.red,
                    ),
                    textAlign: TextAlign.center,
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
                onPressed: _carregando ? null : _entrar,
                child: _carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Entrar',
                        style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CadastroScreen(),
                    ),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: 'Não tem conta? ',
                    style: TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'Criar conta',
                        style: TextStyle(color: Color(0xFFC2463C)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController controller,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}