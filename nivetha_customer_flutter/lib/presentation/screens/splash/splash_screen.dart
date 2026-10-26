
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../auth/login_screen.dart';
import '../main_shell_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _cream = Color(0xFFFFF8ED);
  static const Color _darkBrown = Color(0xFF402719);
  static const Color _brown = Color(0xFF765039);
  static const Color _gold = Color(0xFFD5A64A);

  late final AnimationController _logoController;
  late final AnimationController _textController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textOpacity;

  Timer? _navigationTimer;
  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await _logoController.forward();

    if (!mounted) return;

    await _textController.forward();

    if (!mounted) return;

    _navigationTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        _navigateNext();
      },
    );
  }

  /// First launch: Splash -> Login.
  /// Saved session: Splash -> Home.
  Future<void> _navigateNext() async {
    if (!mounted || _navigationStarted) return;

    _navigationStarted = true;

    bool loggedIn = false;

    try {
      loggedIn = await AuthService.instance.isLoggedIn();
    } catch (error) {
      debugPrint('Unable to restore customer session: $error');
      loggedIn = false;
    }

    if (!mounted) return;

    final Widget destination = loggedIn
        ? const MainShellScreen()
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return destination;
        },
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curvedAnimation);

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          Positioned(
            top: -95,
            right: -85,
            child: _decorativeCircle(
              230,
              _gold.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -85,
            child: _decorativeCircle(
              245,
              _brown.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            top: 90,
            left: 28,
            child: Icon(
              Icons.spa_rounded,
              size: 26,
              color: _gold.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            right: 32,
            bottom: 155,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 27,
              color: _gold.withValues(alpha: 0.65),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: _buildLogo(),
                      ),
                    ),
                    const SizedBox(height: 35),
                    FadeTransition(
                      opacity: _textOpacity,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            const Text(
                              'NIVETHA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _darkBrown,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _goldLine(),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'CATERING SERVICE',
                                    style: TextStyle(
                                      color: _brown,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2.2,
                                    ),
                                  ),
                                ),
                                _goldLine(),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Every Celebration, A Delicious Memory',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _brown,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    Column(
                      children: [
                        const SizedBox(
                          width: 27,
                          height: 27,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_gold),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'PREPARING SOMETHING DELICIOUS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _brown.withValues(alpha: 0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 174,
      height: 174,
      decoration: BoxDecoration(
        color: _darkBrown,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(
          color: _gold,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _darkBrown.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 12,
            left: 12,
            child: _cornerDecoration(),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Transform.scale(
              scaleX: -1,
              child: _cornerDecoration(),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Transform.scale(
              scaleY: -1,
              child: _cornerDecoration(),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Transform.scale(
              scaleX: -1,
              scaleY: -1,
              child: _cornerDecoration(),
            ),
          ),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _gold.withValues(alpha: 0.65),
                width: 1.4,
              ),
              color: Colors.white.withValues(alpha: 0.035),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              size: 64,
              color: _gold,
            ),
          ),
          const Positioned(
            bottom: 31,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFFFE6A8),
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cornerDecoration() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _gold.withValues(alpha: 0.8),
            width: 2,
          ),
          left: BorderSide(
            color: _gold.withValues(alpha: 0.8),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _goldLine() {
    return Container(
      width: 23,
      height: 1.5,
      decoration: BoxDecoration(
        color: _gold,
        borderRadius: BorderRadius.circular(5),
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
