import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextPage;

  const SplashScreen({super.key, required this.nextPage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;
  bool _pendingNavigate = false;
  Timer? _fallbackTimer;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.colorBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _fallbackTimer = Timer(const Duration(milliseconds: 2200), () {
      if (!_hasNavigated) {
        _hasNavigated = true;
        _navigateToNextPage();
      }
    });
  }

  void _navigateToNextPage() {
    if (!mounted) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
      _pendingNavigate = true;
      return;
    }
    _doReplacement();
  }

  void _doReplacement() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget.nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingNavigate && (ModalRoute.of(context)?.isCurrent ?? false)) {
      _pendingNavigate = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          _doReplacement();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: const _BrandedSplash(),
      ),
    );
  }
}

class _BrandedSplash extends StatelessWidget {
  const _BrandedSplash();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/cineprime-logo.png',
                    width: 260,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: 72,
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'GREAT STORIES',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 13,
                      letterSpacing: 4.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'LIVE FOREVER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.colorGold.withValues(alpha: 0.9),
                      fontSize: 13,
                      letterSpacing: 4.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: Text(
                'MOVIES   ·   SERIES   ·   ORIGINALS   ·   MORE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
