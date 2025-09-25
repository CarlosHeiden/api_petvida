// lib/services/api_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api_petvida/models/agendamento.dart';
import 'package:api_petvida/models/animal.dart';
import 'package:api_petvida/models/servicos.dart';
import 'package:api_petvida/utils/constants.dart';
import 'package:logger/logger.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: API_BASE_URL,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'login/',
        data: {'username': username, 'password': password},
        options: Options(contentType: Headers.jsonContentType),
      );
      _logger.d('Resposta completa da API: ${response.data}');

      final token = response.data['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString(
          'currentUser',
          jsonEncode({
            'user_id': response.data['user_id'],
            'email': response.data['email'],
          }),
        );
        await prefs.setString(
          'userAnimals',
          jsonEncode(response.data['animais']),
        );
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      _logger.e('Tipo de erro: ${e.type}\nErro original: ${e.error}\nCódigo: ${e.response?.statusCode}\nDetalhes: ${e.response?.data}');
      return null;
    }
  }

  Future<List<Animal>> getMyAnimals() async {
    final prefs = await SharedPreferences.getInstance();
    final animalsJson = prefs.getString('userAnimals');
    if (animalsJson != null) {
      final List<dynamic> animalsList = jsonDecode(animalsJson);
      return animalsList.map((data) => Animal.fromJson(data)).toList();
    }
    return [];
  }

  Future<List<Agendamento>> getAgendamentos() async {
    final token = await getAuthToken();
    if (token == null) return [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');
      if (userJson == null) {
        return [];
      }
      final userMap = jsonDecode(userJson);
      final userId = userMap['user_id'];

      final response = await _dio.get(
        'agendamentos/',
        queryParameters: {'user_id': userId},
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
      return (response.data as List)
          .map((item) => Agendamento.fromJson(item))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<List<Servicos>> getServicos() async {
    final token = await getAuthToken();
    if (token == null) return [];

    try {
      final response = await _dio.get(
        'servicos/',
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
      return (response.data as List)
          .map((item) => Servicos.fromJson(item))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<void> createAgendamento(Map<String, dynamic> data) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado.');
    }

    try {
      await _dio.post(
        'agendamentos/',
        data: data,
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
    } on DioException catch (e) {
      _logger.e('Erro ao criar agendamento: ${e.response?.statusCode}\nDetalhes: ${e.response?.data}');
      rethrow; 
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }

  // Novo método para obter horários disponíveis
  Future<List<String>> getHorariosDisponiveis({
    required String data,
    required int servicoId,
  }) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado.');
    }

    try {
      final response = await _dio.get(
        'horarios-disponiveis/',
        queryParameters: {
          'data': data,
          'servico_id': servicoId,
        },
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
      
      return List<String>.from(response.data);
    } on DioException catch (e) {
      _logger.e('Erro ao obter horários: ${e.response?.statusCode}\nDetalhes: ${e.response?.data}');
      rethrow;
    }
  }

  // Método de agendamento "com um clique"
  // Esta função foi ajustada para enviar os dados para o endpoint correto.
  Future<void> agendarComUmClique({
    required int idAnimal,
    required int idServicos,
    required String data,
    required String hora,
  }) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado.');
    }

    try {
      final body = {
        'id_animal': idAnimal,
        'id_servico': idServicos,
        'data': data,
        'hora': hora,
      };

      await _dio.post(
        'agendar_servico/', // A rota do back-end que está funcionando
        data: body,
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
    } on DioException catch (e) {
      _logger.e('Erro ao agendar: ${e.response?.statusCode}\nDetalhes: ${e.response?.data}');
      rethrow;
    }
  }
}