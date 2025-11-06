// lib/services/fcm_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  // 🔧 Configurações locais
  static const String djangoBaseUrl = "http://201.35.251.181:8000/api"; // ou seu IP LAN, veja abaixo
  static const String saveTokenEndpoint = "/save-fcm-token/";      // rota Django ajustada
  static String djangoAuthToken = ""; // ⚠️ este será preenchido dinamicamente após login

  // Inicializa o FCM e salva o token no Django
  static Future<void> initializeFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Solicita permissão no iOS (se aplicável)
      await messaging.requestPermission();

      // Obtém o token FCM atual
      final fcmToken = await messaging.getToken();
      print("Token FCM gerado: $fcmToken");

      if (fcmToken != null && djangoAuthToken.isNotEmpty) {
        await sendTokenToDjango(fcmToken);
      } else {
        print("⚠️ Token FCM ou token de autenticação não disponível.");
      }

      // Ouve mudanças no token (em caso de atualização)
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("Novo token FCM gerado: $newToken");
        if (djangoAuthToken.isNotEmpty) {
          sendTokenToDjango(newToken);
        }
      });

    } catch (e) {
      print("❌ Erro ao inicializar FCM: $e");
    }
  }

  static Future<void> sendTokenToDjango(String fcmToken) async {
    final url = Uri.parse("$djangoBaseUrl$saveTokenEndpoint");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $djangoAuthToken",
        },
        body: jsonEncode({"fcm_token": fcmToken}),
      );

      if (response.statusCode == 200) {
        print("✅ Token FCM salvo no Django com sucesso!");
      } else {
        print("⚠️ Falha ao salvar token FCM: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Erro ao enviar token FCM: $e");
    }
  }
}