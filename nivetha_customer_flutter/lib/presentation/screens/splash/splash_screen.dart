
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../main_shell_screen.dart';
import '../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatController;
  late final AnimationController _rotationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.55,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entranceController.forward();
    _floatController.repeat(reverse: true);
    _rotationController.repeat();

    _startNavigation();
  }

  Future<void> _startNavigation() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 2600),
    );

    if (!mounted || _navigationStarted) return;

    _navigationStarted = true;

    bool loggedIn = false;

    try {
      loggedIn = await AuthService.instance.isLoggedIn();
    } catch (_) {
      loggedIn = false;
    }

    if (!mounted) return;

    final Widget destination =
        loggedIn ? const MainShellScreen() : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return destination;
        },
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF102541);
    const deepNavy = Color(0xFF091629);
    const gold = Color(0xFFE5B554);
    const cream = Color(0xFFFFF7E8);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              deepNavy,
              navy,
              Color(0xFF25486A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background circles
            Positioned(
              top: -100,
              right: -90,
              child: _glowCircle(
                size: 280,
                color: gold.withValues(alpha: 0.10),
              ),
            ),

            Positioned(
              bottom: -120,
              left: -100,
              child: _glowCircle(
                size: 330,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),

            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.18,
              left: 30,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 22,
                color: gold.withValues(alpha: 0.65),
              ),
            ),

            Positioned(
              right: 38,
              bottom: MediaQuery.sizeOf(context).height * 0.24,
              child: Icon(
                Icons.star_rounded,
                size: 28,
                color: gold.withValues(alpha: 0.65),
              ),
            ),

            SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: _entranceController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated 3D logo
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _floatController,
                          _rotationController,
                        ]),
                        builder: (context, child) {
                          final floatOffset =
                              math.sin(
                                _floatController.value * math.pi,
                              ) *
                              10;

                          final rotation =
                              math.sin(
                                _rotationController.value *
                                    math.pi *
                                    2,
                              ) *
                              0.045;

                          return Transform.translate(
                            offset: Offset(0, -floatOffset),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0015)
                                ..rotateY(rotation),
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFE8A8),
                                gold,
                                Color(0xFFB77B25),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(42),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.65,
                              ),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: gold.withValues(alpha: 0.28),
                                blurRadius: 35,
                                spreadRadius: 4,
                                offset: const Offset(0, 18),
                              ),
                              const BoxShadow(
                                color: Colors.black26,
                                blurRadius: 18,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 78,
                            color: navy,
                          ),
                        ),
                      ),

                      const SizedBox(height: 42),

                      const Text(
                        'NIVETHA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5,
                          color: cream,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: 85,
                        height: 3,
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'CATERING SERVICE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                          color: gold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Delicious Food • Memorable Moments',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: cream.withValues(alpha: 0.80),
                          letterSpacing: 0.4,
                        ),
                      ),

                      const SizedBox(height: 58),

                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            gold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Preparing something delicious...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: cream.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
