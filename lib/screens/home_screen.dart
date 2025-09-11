// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:api_petvida/models/agendamento.dart';
import 'package:api_petvida/services/api_service.dart';
import 'package:api_petvida/screens/agendamento_screen.dart';
import 'package:api_petvida/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Agendamento>> _agendamentosFuture;

  @override
  void initState() {
    super.initState();
    _agendamentosFuture = _apiService.getAgendamentos();
  }

  void _logout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _agendamentosFuture = _apiService.getAgendamentos();
              });
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: _agendamentosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar agendamentos: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum agendamento encontrado.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final agendamento = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.pets, color: Colors.blueAccent),
                    title: Text(
                      agendamento.nomeServico ?? 'Serviço Desconhecido',
                    ),
                    subtitle: Text(
                      '${agendamento.nomeAnimal} - '
                      '${agendamento.dataAgendamento.day}/${agendamento.dataAgendamento.month} às ${agendamento.horaAgendamento}',
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgendamentoScreen()),
          ).then((value) {
            // Recarrega a lista quando voltar da tela de agendamento
            if (value == true) {
              setState(() {
                _agendamentosFuture = _apiService.getAgendamentos();
              });
            }
          });
        },
        tooltip: 'Novo Agendamento',
        child: const Icon(Icons.add),
      ),
    );
  }
}
