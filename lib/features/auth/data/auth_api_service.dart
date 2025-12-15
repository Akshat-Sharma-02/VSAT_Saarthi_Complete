import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_endpoints.dart';

class AuthApiService {
  final http.Client _client;

  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  // LOGIN WITH USERNAME OR EMAIL
  Future<Map<String, dynamic>> login({
    required String credential,
    required String password,
  }) async {
    final res = await _client.post(
      Uri.parse(ApiEndpoints.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'credential': credential,
        'password': password,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Login failed: ${res.body}');
    }
  }

  // SIGNUP WITH USERNAME
  Future<Map<String, dynamic>> signup({
    required String name,
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    final res = await _client.post(
      Uri.parse(ApiEndpoints.signup),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Signup failed: ${res.body}');
    }
  }

  // VERIFY OTP USING userId
  Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String otp,
  }) async {
    final res = await _client.post(
      Uri.parse(ApiEndpoints.verifyOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'otp': otp,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('OTP verification failed: ${res.body}');
    }
  }

  // GOOGLE LOGIN → BACKEND
  Future<Map<String, dynamic>> loginWithGoogleToken(String idToken) async {
    final res = await _client.post(
      Uri.parse(ApiEndpoints.googleLogin),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': idToken,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Google login failed: ${res.body}');
    }
  }

  // CHECK USERNAME AVAILABILITY
  Future<Map<String, dynamic>> checkUsername(String username) async {
    final res = await _client.post(
      Uri.parse(ApiEndpoints.checkUsername),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Username check failed: ${res.body}');
    }
  }
}