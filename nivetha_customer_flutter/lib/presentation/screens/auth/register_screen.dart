
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import 'login_screen.dart';

const Color _cream = Color(0xFFFFF7E8);
const Color _gold = Color(0xFFC58B19);
const Color _darkGold = Color(0xFF925D0B);
const Color _brown = Color(0xFF45250E);
const Color _green = Color(0xFF167331);

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

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _brown),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE4D8C4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE4D8C4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  String _errorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();

    if (message.isEmpty || message == 'null') {
      return 'Registration failed. Please try again.';
    }

    return message;
  }

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    if (_loading) return;

    if (!_formKey.currentState!.validate()) return;

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
        MaterialPageRoute(
          builder: (_) => const RegistrationSuccessScreen(),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed:
                          _loading ? null : () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    const Icon(Icons.language, size: 20),
                    const SizedBox(width: 6),
                    const Text('English'),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.restaurant_menu,
                  size: 54,
                  color: _darkGold,
                ),
                const SizedBox(height: 2),
                const Text(
                  'NIVETHA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _brown,
                    fontSize: 35,
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join us to book your catering service',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 26),
                TextFormField(
                  controller: _nameController,
                  enabled: !_loading,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    'Full Name',
                    Icons.person_outline,
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? '';

                    if (name.isEmpty) {
                      return 'Please enter your full name';
                    }

                    if (name.length < 2) {
                      return 'Name must contain at least 2 characters';
                    }

                    if (name.length > 100) {
                      return 'Name cannot exceed 100 characters';
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
                  decoration: _inputDecoration(
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
                  decoration: _inputDecoration(
                    'Email Address (Optional)',
                    Icons.email_outlined,
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) return null;

                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  enabled: !_loading,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    'Password',
                    Icons.lock_outline,
                    suffixIcon: IconButton(
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if ((value?.length ?? 0) < 6) {
                      return 'Password must contain at least 6 characters';
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
                  decoration: _inputDecoration(
                    'Confirm Password',
                    Icons.lock_outline,
                    suffixIcon: IconButton(
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                _hideConfirmPassword =
                                    !_hideConfirmPassword;
                              });
                            },
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
                      : (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                  activeColor: _gold,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'I agree to the Terms & Conditions and Privacy Policy',
                    style: TextStyle(
                      fontSize: 13,
                      color: _brown,
                    ),
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
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
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
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: _brown),
                    ),
                    GestureDetector(
                      onTap: _loading
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
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
    );
  }
}

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 55),
              const Icon(
                Icons.check_circle,
                color: _green,
                size: 100,
              ),
              const SizedBox(height: 22),
              const Text(
                'Account Created\nSuccessfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _green,
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Welcome to Nivetha Catering Service',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _green,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your account has been created successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: _brown,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.restaurant_menu_rounded,
                size: 100,
                color: _darkGold,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
