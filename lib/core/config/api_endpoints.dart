class ApiEndpoints {
  static const String baseUrl = "https://vsat-auth.onrender.com";

  static const String signup = "$baseUrl/auth/signup";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String login = "$baseUrl/auth/login";
  static const String googleLogin = "$baseUrl/auth/google-login";
  static const String checkUsername = "$baseUrl/auth/check-username";
}