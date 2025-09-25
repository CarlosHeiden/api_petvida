// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:api_petvida/models/agendamento.dart';
import 'package:api_petvida/services/api_service.dart';
import 'package:api_petvida/screens/login_screen.dart';
import 'package:api_petvida/screens/one_click_agendamento_screen.dart'; // Importação da nova tela

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

  // Função para recarregar a lista de agendamentos
  void _recarregarAgendamentos() {
    setState(() {
      _agendamentosFuture = _apiService.getAgendamentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        actions: [
          // Novo botão para agendamento rápido
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OneClickAgendamentoScreen(),
                ),
              ).then((value) {
                // Recarrega a lista quando voltar da tela de agendamento rápido
                if (value == true) {
                  _recarregarAgendamentos();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregarAgendamentos,
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
            MaterialPageRoute(builder: (context) => const OneClickAgendamentoScreen()),
          ).then((value) {
            if (value == true) {
              _recarregarAgendamentos();
            }
          });
        },
        tooltip: 'Novo Agendamento Rapido',
        child: const Icon(Icons.add),
      ),
    );
  }
}