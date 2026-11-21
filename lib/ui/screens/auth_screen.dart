import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {

  /// Экран авторизации/регистрации
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  
  // Флаг режима (true - вход, false - регистрация)
  bool _isLogin = true; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        // Расшифровываем понятные ошибки (как требуют в аттестации)
        switch (e.code) {
          case 'user-not-found':
          case 'invalid-credential':
            _errorMessage = 'Неверный email или пароль';
            break;
          case 'email-already-in-use':
            _errorMessage = 'Такой аккаунт уже существует';
            break;
          case 'weak-password':
            _errorMessage = 'Пароль должен быть не менее 6 символов';
            break;
          case 'invalid-email':
            _errorMessage = 'Некорректный email';
            break;
          case 'missing-password':
            _errorMessage = 'Некорректный пароль';
            break;
          case 'network-request-failed':
            _errorMessage = 'Проверьте интернет соединение';
            break;
          default:
            _errorMessage = 'Ошибка: ${e.code}';
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Вход в Каталог' : 'Регистрация')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin; // Переключаем режим
                          _errorMessage = null; // Сбрасываем ошибку
                        });
                      },
                      child: Text(
                        _isLogin ? 'Нет аккаунта? Зарегистрироваться' : 'Уже есть аккаунт? Войти',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}