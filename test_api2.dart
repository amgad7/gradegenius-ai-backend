import 'package:dio/dio.dart';

void main() async {
  try {
    final dio = Dio();
    final response = await dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyATJiHN8Xl0SUCxq6himAIBzUH_lY7QAb0',
      data: {
        "contents": [
          {
            "parts": [
              {"text": "Hello, is this working?"}
            ]
          }
        ]
      },
    );
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.data}');
  } on DioException catch (e) {
    print('Dio Error: ${e.response?.statusCode}');
    print('Error Data: ${e.response?.data}');
  } catch (e) {
    print('Unknown Error: $e');
  }
}
