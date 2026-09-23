import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';

class LogoutDialog extends StatelessWidget {
  final Future<void> Function() onConfirm;

  const LogoutDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          gradient: AppColors.brandTextGradient,
        ),
        padding: const EdgeInsets.all(1.6),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(26.4)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF173044), Color(0xFF0B1018), Color(0xFF1A150C)],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                top: -36,
                left: -28,
                child: _Glow(color: Color(0x55E8B931), size: 140),
              ),
              const Positioned(
                top: -48,
                right: -36,
                child: _Glow(color: Color(0x443EC6E0), size: 160),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/cineprime-icon.png',
                      height: 72,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Leaving Cineprime?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your place is saved. Sign back in whenever you want to keep watching.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.colorTextSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.colorPrimaryLight, width: 1.4),
                              ),
                              child: const Text(
                                'Stay',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: AppColors.colorPrimaryLight,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: onConfirm,
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Text(
                                'Log out',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: AppColors.colorOnGold,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
