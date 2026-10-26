
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../main_shell_screen.dart';
import 'login_screen.dart';

const Color _cream = Color(0xFFFFF7E8);
const Color _gold = Color(0xFFC58B19);
const Color _darkGold = Color(0xFF925D0B);
const Color _brown = Color(0xFF45250E);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService.instance;

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    if (_loading || !_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      _showMessage('Please accept the Terms and Conditions.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        phone: _mobileController.text.trim(),
        email: _emailController.text.trim(),
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
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          child: Center(
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
                          color: _brown,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 58,
                      color: _darkGold,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'NIVETHA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _brown,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      'C A T E R I N G  S E R V I C E',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _brown,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: _brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join us to book your catering service',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF555555)),
                    ),
                    const SizedBox(height: 26),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_loading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'Full Name',
                        Icons.person_outline,
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';

                        if (name.length < 2) {
                          return 'Enter your full name';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _mobileController,
                      enabled: !_loading,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      maxLength: 10,
                      decoration: _decoration(
                        'Mobile Number',
                        Icons.phone_outlined,
                      ).copyWith(counterText: ''),
                      validator: (value) {
                        if (!RegExp(r'^[0-9]{10}$')
                            .hasMatch(value?.trim() ?? '')) {
                          return 'Enter a valid 10-digit mobile number';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'Email Address (Optional)',
                        Icons.email_outlined,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) return null;

                        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(email)
                            ? null
                            : 'Enter a valid email address';
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_loading,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.next,
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
                        if ((value?.length ?? 0) < 6) {
                          return 'Use at least 6 characters';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !_loading,
                      obscureText: _hideConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _createAccount(),
                      decoration: _decoration(
                        'Confirm Password',
                        Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: _loading
                              ? null
                              : () => setState(
                                    () => _hideConfirmPassword =
                                        !_hideConfirmPassword,
                                  ),
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _acceptedTerms,
                      onChanged: _loading
                          ? null
                          : (value) => setState(
                                () => _acceptedTerms = value ?? false,
                              ),
                      activeColor: _gold,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'I agree to the Terms & Conditions and Privacy Policy',
                        style: TextStyle(fontSize: 13, color: _brown),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              _gold.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: _darkGold,
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
      prefixIcon: Icon(icon, color: _darkGold),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE4D8C4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _gold, width: 1.5),
      ),
    );
  }
}
