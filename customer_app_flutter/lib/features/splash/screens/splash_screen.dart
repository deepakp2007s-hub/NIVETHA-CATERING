import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _openNext();
  }

  Future<void> _openNext() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 1400)),
      Future<void>.delayed(Duration.zero, () async {
        if (auth.isInitializing) {
          while (auth.isInitializing && mounted) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
        }
      }),
    ]);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      auth.isAuthenticated ? AppRouter.home : AppRouter.login,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: AppColors.accentGradient,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: AppColors.background,
                      size: 46,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'NIVETHA',
                    style: TextStyle(
                      fontFamily: 'BodoniModa',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Function Catering',
                    style: TextStyle(
                      color: AppColors.gold,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
