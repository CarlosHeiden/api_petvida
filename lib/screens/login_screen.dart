// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:api_petvida/services/api_service.dart';
import 'package:api_petvida/screens/home_screen.dart'; // Tela de destino após o login

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    final token = await _apiService.login(username, password);

    setState(() {
      _isLoading = false;
    });

    if (token != null) {
      // Login bem-sucedido, navega para a tela inicial
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Login falhou, exibe uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha no login. Verifique suas credenciais.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login PetVida'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nome de usuário',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        50,
                      ), // Botão de largura total
                    ),
                    child: const Text('Entrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
