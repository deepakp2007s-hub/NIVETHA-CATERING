
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../main_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _entranceController;
  late final AnimationController _floatController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  static const Color _navy = Color(0xFF102541);
  static const Color _gold = Color(0xFFD9A441);
  static const Color _cream = Color(0xFFFFF8EC);

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entranceController.forward();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.login(
        emailOrPhone: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainShellScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      final message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ApiException: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty
                ? 'Login failed. Please check your details.'
                : message,
          ),
          backgroundColor: const Color(0xFFB3261E),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          // Decorative background
          Positioned(
            top: -100,
            right: -90,
            child: _decorativeCircle(
              260,
              _gold.withValues(alpha: 0.13),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -100,
            child: _decorativeCircle(
              300,
              _navy.withValues(alpha: 0.07),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 24, 25, 28),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          // Floating 3D-style logo
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, child) {
                              final offset = math.sin(
                                    _floatController.value * math.pi,
                                  ) *
                                  7;

                              return Transform.translate(
                                offset: Offset(0, -offset),
                                child: child,
                              );
                            },
                            child: Center(
                              child: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFE6A2),
                                      Color(0xFFD9A441),
                                      Color(0xFFAD761F),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(34),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _gold.withValues(alpha: 0.32),
                                      blurRadius: 25,
                                      offset: const Offset(0, 13),
                                    ),
                                    const BoxShadow(
                                      color: Color(0x18000000),
                                      blurRadius: 12,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu_rounded,
                                  size: 59,
                                  color: _navy,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 27),

                          const Text(
                            'Welcome Back!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _navy,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),

                          const SizedBox(height: 9),

                          const Text(
                            'NIVETHA CATERING SERVICE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF987022),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Login to manage your catering bookings.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blueGrey.shade600,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 35),

                          _fieldLabel('Email or Mobile Number'),

                          const SizedBox(height: 9),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.username,
                            ],
                            decoration: _inputDecoration(
                              hint: 'Enter email or mobile number',
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter your email or mobile number';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 22),

                          _fieldLabel('Password'),

                          const SizedBox(height: 9),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [
                              AutofillHints.password,
                            ],
                            onFieldSubmitted: (_) => _login(),
                            decoration: _inputDecoration(
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                            ).copyWith(
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                        !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.blueGrey.shade500,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your password';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                          CheckboxListTile(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? true;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            activeColor: _navy,
                            dense: true,
                            title: const Text(
                              'Remember me',
                              style: TextStyle(
                                color: _navy,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 19),

                          // Gold gradient login button
                          Container(
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFE5A0),
                                  _gold,
                                  Color(0xFFBB852C),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: _gold.withValues(alpha: 0.32),
                                  blurRadius: 17,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor:
                                    Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: _navy,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            color: _navy,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: _navy,
                                          size: 21,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 17,
                                color: Colors.blueGrey.shade500,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'Secure customer login',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Delicious Food • Memorable Moments',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blueGrey.shade500,
                              fontSize: 12,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _navy,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.blueGrey.shade300,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFB78A36),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFE8DFD0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: _gold,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFB3261E),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFB3261E),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
