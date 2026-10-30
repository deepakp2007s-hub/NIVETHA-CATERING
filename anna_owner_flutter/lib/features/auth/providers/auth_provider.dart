import 'package:flutter/foundation.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final SecureStorage secureStorage;

  AuthProvider({
    required this.authService,
    required this.secureStorage,
  });

  bool isLoading = false;
  bool isInitializing = true;
  bool isAuthenticated = false;

  String? errorMessage;
  String? ownerEmail;

  Future<void> initialize() async {
    try {
      final token = await secureStorage.readToken();
      final email = await secureStorage.readEmail();

      if (token != null &&
          token.isNotEmpty &&
          email != null &&
          email.isNotEmpty) {
        isAuthenticated = true;
        ownerEmail = email;
      }
    } catch (_) {
      await secureStorage.clearSession();
      isAuthenticated = false;
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (isLoading) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await authService.login(
        email: email,
        password: password,
      );

      final token = result['access_token'] as String;
      final owner = result['owner'] as Map<String, dynamic>;
      final authenticatedEmail = owner['email'] as String? ?? email.trim();

      await secureStorage.saveSession(
        token: token,
        email: authenticatedEmail,
      );

      ownerEmail = authenticatedEmail;
      isAuthenticated = true;

      return true;
    } on ApiConfigurationException catch (error) {
      errorMessage = error.message;
      return false;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Unable to login. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await secureStorage.clearSession();

    isAuthenticated = false;
    ownerEmail = null;
    errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}