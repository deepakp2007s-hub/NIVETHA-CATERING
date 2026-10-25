
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../main_shell_screen.dart';

const Color cream = Color(0xFFFFF7E8);
const Color gold = Color(0xFFC58B19);
const Color darkGold = Color(0xFF925D0B);
const Color brown = Color(0xFF45250E);
const Color green = Color(0xFF167331);

class AuthScreens extends StatelessWidget {
  const AuthScreens({super.key});

  @override
  Widget build(BuildContext context) => const WelcomeScreen();
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.small = false});

  final bool small;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: small ? 66 : 92,
          width: small ? 66 : 92,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: gold, width: 2),
          ),
          child: Icon(
            Icons.restaurant_menu_rounded,
            size: small ? 36 : 52,
            color: darkGold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'NIVETHA',
          style: TextStyle(
            color: brown,
            fontSize: small ? 28 : 38,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const Text(
          'C A T E R I N G  S E R V I C E',
          style: TextStyle(
            color: brown,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class FoodBanner extends StatelessWidget {
  const FoodBanner({super.key, this.height = 230});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=1000&q=85',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFEAD6AC),
          alignment: Alignment.center,
          child: const Icon(
            Icons.restaurant,
            color: darkGold,
            size: 80,
          ),
        ),
      ),
    );
  }
}

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.white,
          disabledBackgroundColor: gold.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const BrandLogo(),
            const SizedBox(height: 20),
            const Text(
              'Delicious Food\nFor Memorable Moments',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: brown,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Expanded(child: FoodBanner(height: 300)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              decoration: const BoxDecoration(
                color: brown,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Traditional Taste\nFor Every Occasion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cream,
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 22),
                  GoldButton(
                    text: 'Login  →',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: gold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();

final AuthService _authService = AuthService.instance;


  bool _obscurePassword = true;
  bool _useEmail = false;
  bool _rememberMe = true;
  bool _loading = false;

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: darkGold),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.8),
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
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? 'Something went wrong. Please try again.' : message;
  }

  Future<void> _login() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    if (_useEmail) {
      _showMessage(
        'Email login is not available yet. Please select Mobile.',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.login(
        emailOrPhone: _identityController.text.trim(),
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
      _showMessage(_errorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _socialLoginSetup(String provider) {
    _showMessage(
      '$provider login is not configured. Please use mobile login.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: _loading ? null : () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back, color: brown),
              ),
            ),
            const SizedBox(height: 8),
            const BrandLogo(small: true),
            const SizedBox(height: 24),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Login to book your catering service',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Mobile'),
                  icon: Icon(Icons.phone_android),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Email'),
                  icon: Icon(Icons.email_outlined),
                ),
              ],
              selected: {_useEmail},
              onSelectionChanged: _loading
                  ? null
                  : (value) {
                      setState(() => _useEmail = value.first);
                      _identityController.clear();
                    },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: gold,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _identityController,
              enabled: !_loading,
              keyboardType: _useEmail
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              decoration: _decoration(
                _useEmail ? 'Email Address' : 'Mobile Number',
                _useEmail ? Icons.email_outlined : Icons.phone_outlined,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';

                if (_useEmail) {
                  return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(text)
                      ? null
                      : 'Enter a valid email address';
                }

                return RegExp(r'^[0-9]{10}$').hasMatch(text)
                    ? null
                    : 'Enter a valid 10-digit mobile number';
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              enabled: !_loading,
              obscureText: _obscurePassword,
              decoration: _decoration(
                'Password',
                Icons.lock_outline,
                suffix: IconButton(
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => (value ?? '').length >= 6
                  ? null
                  : 'Password must be at least 6 characters',
            ),
            const SizedBox(height: 8),
            Row(
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
                const Spacer(),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => _showMessage(
                            'Password recovery is not connected yet.',
                          ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: darkGold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GoldButton(
              text: _loading ? 'Please wait...' : 'Login',
              onPressed: _loading ? null : _login,
            ),
            if (_loading) ...[
              const SizedBox(height: 14),
              const CircularProgressIndicator(color: gold),
            ],
            const SizedBox(height: 22),
            const Row(
              children: [
                Expanded(child: Divider(color: Color(0xFFD8C5A8))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR CONTINUE WITH',
                    style: TextStyle(
                      color: brown,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Color(0xFFD8C5A8))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _loading ? null : () => _socialLoginSetup('Google'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: brown,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE4D8C4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Continue with Google'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    _loading ? null : () => _socialLoginSetup('Facebook'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.facebook, size: 25),
                    SizedBox(width: 12),
                    Text('Continue with Facebook'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: _loading
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
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
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

final AuthService _authService = AuthService.instance;


  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: darkGold),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.8),
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
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty
        ? 'Registration failed. Please try again.'
        : message;
  }

  Future<void> _register() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      _showMessage('Please accept the Terms and Conditions.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.register(
        name: _name.text.trim(),
        phone: _mobile.text.trim(),
        password: _password.text,
        email: _email.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const SuccessScreen(),
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
    return AuthBackground(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: _loading ? null : () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back, color: brown),
              ),
            ),
            const SizedBox(height: 8),
            const BrandLogo(small: true),
            const SizedBox(height: 24),
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Join us to book your catering service'),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              enabled: !_loading,
              textCapitalization: TextCapitalization.words,
              decoration: _fieldDecoration('Full Name', Icons.person_outline),
              validator: (value) {
                final name = value?.trim() ?? '';
                return name.length >= 2 ? null : 'Enter your full name';
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _mobile,
              enabled: !_loading,
              keyboardType: TextInputType.phone,
              decoration: _fieldDecoration(
                'Mobile Number',
                Icons.phone_outlined,
              ),
              validator: (value) =>
                  RegExp(r'^[0-9]{10}$').hasMatch(value?.trim() ?? '')
                      ? null
                      : 'Enter a valid 10-digit mobile number',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              decoration: _fieldDecoration(
                'Email Address',
                Icons.email_outlined,
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return null;

                return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)
                    ? null
                    : 'Enter a valid email address';
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              enabled: !_loading,
              obscureText: _hidePassword,
              decoration: _fieldDecoration(
                'Password',
                Icons.lock_outline,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) => (value?.length ?? 0) >= 6
                  ? null
                  : 'Use at least 6 characters',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPassword,
              enabled: !_loading,
              obscureText: _hideConfirmPassword,
              decoration: _fieldDecoration(
                'Confirm Password',
                Icons.lock_outline,
                suffix: IconButton(
                  onPressed: () => setState(
                    () => _hideConfirmPassword = !_hideConfirmPassword,
                  ),
                  icon: Icon(
                    _hideConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) =>
                  value == _password.text ? null : 'Passwords do not match',
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              value: _acceptedTerms,
              activeColor: gold,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'I agree to the Terms & Conditions and Privacy Policy',
                style: TextStyle(fontSize: 13),
              ),
              onChanged: _loading
                  ? null
                  : (value) =>
                      setState(() => _acceptedTerms = value ?? false),
            ),
            const SizedBox(height: 12),
            GoldButton(
              text: _loading ? 'Creating account...' : 'Create Account',
              onPressed: _loading ? null : _register,
            ),
            if (_loading) ...[
              const SizedBox(height: 14),
              const CircularProgressIndicator(color: gold),
            ],
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text('Already have an account? '),
                GestureDetector(
                  onTap: _loading
                      ? null
                      : () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                  child: const Text(
                    'Login',
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
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 55),
            const Icon(Icons.check_circle, color: green, size: 100),
            const SizedBox(height: 22),
            const Text(
              'Account Created\nSuccessfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: green,
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
                color: green,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your account has been created successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: brown),
            ),
            const SizedBox(height: 35),
            const Expanded(child: FoodBanner(height: 300)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: GoldButton(
                text: 'Continue to Home  →',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MainShellScreen(),
                  ),
                  (route) => false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
