import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  static const List<String> hosts = ['http://192.168.1.11:8080', 'http://192.168.1.132:8080'];
  static const String basePath = '/api/v1/auth/login';
  static final storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login(String email, String password) async {
    for (String host in hosts) {
      try {
        final url = '$host$basePath';
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final authToken = responseBody['authToken'];
          final userRole = responseBody['user']['role'];
          await storage.write(key: 'authToken', value: authToken);
          await storage.write(key: 'userRole', value: userRole);
          return {'success': true, 'role': userRole};
        } else {
          print('Failed to log in at $host: ${response.body}');
        }
      } catch (e) {
        print('Failed to connect to $host: $e');
      }
    }

    return {'success': false, 'error': 'Unable to log in on any server'};
  }
}
