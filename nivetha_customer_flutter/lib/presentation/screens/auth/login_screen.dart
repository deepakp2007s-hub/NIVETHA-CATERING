
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../main_shell_screen.dart';
import 'register_screen.dart';

const Color cream = Color(0xFFFFF7E8);
const Color gold = Color(0xFFC58B19);
const Color darkGold = Color(0xFF925D0B);
const Color brown = Color(0xFF45250E);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService.instance;

  bool _loading = false;
  bool _hidePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_loading || !_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _authService.login(
        emailOrPhone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const MainShellScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      _showMessage(_errorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.maybePop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: brown,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 68,
                      color: darkGold,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'NIVETHA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: brown,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      'C A T E R I N G  S E R V I C E',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: brown,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: brown,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Login to book your catering service',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_loading,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: _decoration(
                        'Mobile Number',
                        Icons.phone_outlined,
                      ).copyWith(counterText: ''),
                      validator: (value) {
                        final phone = value?.trim() ?? '';

                        if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                          return 'Enter a valid 10-digit mobile number';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_loading,
                      obscureText: _hidePassword,
                      decoration: _decoration(
                        'Password',
                        Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: _loading
                              ? null
                              : () => setState(
                                    () => _hidePassword = !_hidePassword,
                                  ),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: gold,
                              onChanged: _loading
                                  ? null
                                  : (value) => setState(
                                        () => _rememberMe = value ?? false,
                                      ),
                            ),
                            const Text('Remember me'),
                          ],
                        ),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => _showMessage(
                                    'Password recovery is not available yet.',
                                  ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: darkGold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              gold.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const RegisterScreen(),
                                    ),
                                  ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: darkGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: darkGold),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE4D8C4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
    );
  }
}
