class ApiConstants {
  // TODO: Replace with actual backend URL
<<<<<<< Updated upstream
  //static const String baseUrl = 'http://localhost:8000'; // For development
  static const String baseUrl = 'http://10.0.2.2:8000';
=======
  static const String baseUrl = 'http://localhost:8000'; // For development
>>>>>>> Stashed changes

  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/profile';

<<<<<<< Updated upstream
=======
  // Posts endpoints
  static const String posts = '/posts';
  static const String myPosts = '/posts/my-posts';
  static String userPosts(int userId) => '/posts/user/$userId';
  static String postById(int postId) => '/posts/$postId';
  static String deletePost(int postId) => '/posts/$postId';

>>>>>>> Stashed changes
  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
