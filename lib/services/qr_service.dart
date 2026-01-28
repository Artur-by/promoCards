import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/qr_data.dart';

class QRServiceException implements Exception {
  final String message;
  final bool isNotFound;

  QRServiceException(this.message, {this.isNotFound = false});

  @override
  String toString() => message;
}

class QRService {
   // local http://192.168.3.99:8080
  // prod http://1c.ntsretail.by:8880
  static const String baseUrl = 'http://1c.ntsretail.by:8880';

  Future<QRData> getQRData(String cardId) async {
    final url = Uri.parse('$baseUrl/exec?action=GetQR.getQR&p=$cardId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        // Проверяем, возможно backend возвращает ошибку в JSON
        if (jsonData.containsKey('error') ||
            jsonData.containsKey('message') &&
                (jsonData['message']
                        .toString()
                        .toLowerCase()
                        .contains('не найдена') ||
                    jsonData['message']
                        .toString()
                        .toLowerCase()
                        .contains('not found'))) {
          throw QRServiceException(
            'Карта с ID $cardId не найдена',
            isNotFound: true,
          );
        }

        return QRData.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw QRServiceException(
          'Карта с ID $cardId не найдена',
          isNotFound: true,
        );
      } else {
        throw QRServiceException(
            'Не удалось загрузить данные: ${response.statusCode}');
      }
    } on QRServiceException {
      rethrow;
    } catch (e) {
      // Проверяем, не является ли это ошибкой подключения
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw QRServiceException(
            'Не удалось подключиться к серверу. Проверьте, что backend запущен.');
      }
      throw QRServiceException('Ошибка при получении данных: $e');
    }
  }
}


