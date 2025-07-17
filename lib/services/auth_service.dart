import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  final ApiService _apiService = ApiService();

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post(
        '/auth/v1/token?grant_type=password',
        {'email': email, 'password': password},
      );

      final accessToken = response['access_token'];
      if (accessToken == null) {
        _setError('Login failed: No access token');
        return false;
      }

      _apiService.setAuthToken(accessToken);

      final userResponse = await _apiService.get('/auth/v1/user');
      _currentUser = UserModel.fromJson(userResponse);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
    Map<String, dynamic> userData, {
    required String name,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post('/auth/v1/signup', {
        'email': userData['email'],
        'password': userData['password'],
        'data': {'name': userData['name'], 'phone': userData['phone']},
      });

      final accessToken = response['access_token'];
      if (accessToken == null) {
        _setError('Registration failed: No access token');
        return false;
      }

      _apiService.setAuthToken(accessToken);

      final userResponse = await _apiService.get('/auth/v1/user');
      _currentUser = UserModel.fromJson(userResponse);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
