import 'package:flutter/foundation.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);
  final AuthRepository _repository;

  Customer? customer;
  bool isInitializing = true;
  bool isLoading = false;
  String? errorMessage;
  bool get isAuthenticated => customer != null;

  Future<void> initialize() async {
    try {
      if (await _repository.hasToken()) {
        customer = await _repository.loadProfile();
      }
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _repository.logout();
      }
      customer = null;
    } catch (_) {
      customer = null;
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) => _run(() async {
        customer = await _repository.login(email, password);
      });

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) =>
      _run(() async {
        customer = await _repository.register(
          name: name,
          email: email,
          phone: phone,
          password: password,
        );
      });

  Future<void> logout() async {
    await _repository.logout();
    customer = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (error) {
      errorMessage = error is ApiException ? error.message : error.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
