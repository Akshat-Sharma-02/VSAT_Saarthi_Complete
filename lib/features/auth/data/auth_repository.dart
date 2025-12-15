import 'package:shared_preferences/shared_preferences.dart';
import 'auth_api_service.dart';

class AuthRepository {
  final AuthApiService _api;

  AuthRepository({AuthApiService? api}) : _api = api ?? AuthApiService();

  // NORMAL LOGIN (USERNAME OR EMAIL)
  Future<Map<String, dynamic>> login({
    required String credential, // username OR email
    required String password,
  }) async {
    final res = await _api.login(
      credential: credential,
      password: password,
    );

    // SAVE JWT TOKEN LOCALLY
    if (res.containsKey('token')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', res['token']);
    }

    return res;
  }

  // SIGNUP WITH USERNAME + EMAIL + PASSWORD + PHONE
  Future<Map<String, dynamic>> signup({
    required String name,
    required String username,
    required String email,
    required String password,
    String? phone,
  }) =>
      _api.signup(
        name: name,
        username: username,
        email: email,
        password: password,
        phone: phone,
      );

  // VERIFY OTP (BACKEND BASED ON userId)
  Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String otp,
  }) =>
      _api.verifyOtp(userId: userId, otp: otp);

  // GOOGLE LOGIN → SAVE TOKEN
  Future<Map<String, dynamic>> loginWithGoogleToken(String idToken) async {
    final res = await _api.loginWithGoogleToken(idToken);

    if (res.containsKey('token')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', res['token']);
    }

    return res;
  }

  // CHECK USERNAME AVAILABILITY
  Future<Map<String, dynamic>> checkUsername(String username) =>
      _api.checkUsername(username);

  // CHECK IF USER IS ALREADY LOGGED IN
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('jwt_token');
  }

  // LOGOUT USER (CLEAR TOKEN)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // GET SAVED TOKEN (FOR AUTH HEADERS LATER)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}