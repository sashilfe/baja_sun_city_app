import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class NotificationService {
  // O conteúdo do seu arquivo JSON baixado do Firebase
  final String apiKey =
      dotenv.env['NOTIFICATION_API_KEY'] ?? 'chave_nao_encontrada';

  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  Future<String> _getAccessToken() async {
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(apiKey),
      _scopes,
    );

    final accessToken = client.credentials.accessToken.data;
    client.close();
    return accessToken;
  }

  Future<void> enviarPushV1(String token, String title, String body) async {
    try {
      final String accessToken = await _getAccessToken();
      final Map<String, dynamic> credentials = jsonDecode(apiKey);
      final String projectId = credentials['project_id']!;

      final url =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'webpush': {
              'fcm_options': {
                'link': 'https://seu-app-mentes.web.app', // Link de destino
              }
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Notificação V1 entregue com sucesso!");
      } else {
        print("❌ Erro FCM V1: ${response.body}");
      }
    } catch (e) {
      print("❌ Erro ao processar autenticação V1: $e");
    }
  }
}
