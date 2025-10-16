class ApiConstants {
  // TODO: Replace with actual backend URL
  //static const String baseUrl = 'http://localhost:8000'; // For development
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/profile';
  
  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
