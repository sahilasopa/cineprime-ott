import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/media/media_item.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showGlow;

  const AppBackground({
    super.key,
    required this.child,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.screenGradient),
      child: Stack(
        children: [
          if (showGlow) const Positioned.fill(child: IgnorePointer(child: _BrandWash())),
          child,
        ],
      ),
    );
  }
}

class _BrandWash extends StatelessWidget {
  const _BrandWash();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BrandWashPainter(), child: const SizedBox.expand());
  }
}

class _BrandWashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void blob(Offset center, double radius, Color color) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color, Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    blob(Offset(size.width * 0.08, size.height * 0.06), size.width * 0.78, AppColors.colorPrimary.withValues(alpha: 0.20));
    blob(Offset(size.width * 0.96, size.height * 0.16), size.width * 0.58, AppColors.colorPrimaryLight.withValues(alpha: 0.16));
    blob(Offset(size.width * 0.82, size.height * 0.94), size.width * 0.64, AppColors.colorAccent.withValues(alpha: 0.14));
    blob(Offset(size.width * 0.04, size.height * 0.88), size.width * 0.46, AppColors.colorPrimaryDark.withValues(alpha: 0.18));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrandMark extends StatelessWidget {
  final double height;
  final bool showWordmark;

  const BrandMark({
    super.key,
    this.height = 56,
    this.showWordmark = false,
  });

  @override
  Widget build(BuildContext context) {
    // Full logo already includes the wordmark; icon is for compact marks.
    if (showWordmark) {
      return Image.asset(
        'assets/images/cineprime-logo.png',
        height: height,
        fit: BoxFit.contain,
      );
    }
    return Image.asset(
      'assets/images/cineprime-icon.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final EdgeInsets margin;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 54,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.colorPrimary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorOnGold),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.colorOnGold, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.colorOnGold,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLength;
  final String? errorText;
  final Widget? suffix;
  final VoidCallback? onEditingComplete;

  const DarkField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.errorText,
    this.suffix,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.colorInputFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError ? Colors.redAccent : AppColors.colorInputBorder,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: AppColors.colorPrimary,
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.colorHint, fontSize: 15),
              prefixIcon: Icon(icon, color: AppColors.colorHint, size: 20),
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onEditingComplete: onEditingComplete,
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class SocialCircleButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final Color fill;
  final Color foreground;
  final Color border;

  const SocialCircleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.fill = Colors.white,
    this.foreground = AppColors.colorOnGold,
    this.border = AppColors.colorPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? labelColor;
  final bool showChevron;
  final Widget? trailing;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconColor,
    this.labelColor,
    this.showChevron = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Colors.white;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.colorSurfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.colorTextMuted,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTextStyles.sectionTitle),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('See All', style: AppTextStyles.seeAll),
            ),
        ],
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? background;
  final Color? iconColor;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.background,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background ?? Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: size * 0.46),
      ),
    );
  }
}

class CategoryChipBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryChipBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 22),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  labels[index],
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.colorTextMuted,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  width: selected ? 22 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CineprimeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showDownloads;

  const CineprimeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.showDownloads,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_NavSpec>[
      const _NavSpec(Icons.home_rounded, Icons.home_outlined, 'Home'),
      const _NavSpec(Icons.search_rounded, Icons.search_rounded, 'Explore'),
      const _NavSpec(Icons.bookmark_add_rounded, Icons.bookmark_add_outlined, 'My List'),
      if (showDownloads) const _NavSpec(Icons.download_rounded, Icons.download_outlined, 'Downloads'),
      const _NavSpec(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorBackground.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = currentIndex == index;
              final spec = items[index];
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: selected ? 18 : 0,
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.colorPrimary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Icon(
                        selected ? spec.selectedIcon : spec.icon,
                        color: selected ? AppColors.colorPrimary : AppColors.colorTextMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spec.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? AppColors.colorPrimary : AppColors.colorTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  const _NavSpec(this.selectedIcon, this.icon, this.label);
}

class GlassDialog extends StatelessWidget {
  final Widget child;

  const GlassDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.colorBackground.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.colorPrimary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

String mediaMetaLine(BaseItem item) {
  final parts = <String>[];
  if (item.categories.isNotEmpty) {
    parts.add(item.categories.first);
  }
  if (item.showReleaseTime) {
    parts.add('${item.releaseTime.year}');
  }
  if (item.length.isNotEmpty) {
    parts.add(item.length);
  } else if (item.lengthSeconds > 0) {
    final hours = item.lengthSeconds ~/ 3600;
    final minutes = (item.lengthSeconds % 3600) ~/ 60;
    parts.add(hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m');
  }
  String age = '';
  if (item.ageRating != null && item.ageLimit != null) {
    age = '${item.ageRating} ${item.ageLimit}+';
  } else if (item.ageRating != null) {
    age = item.ageRating!;
  } else if (item.ageLimit != null) {
    age = 'U/A ${item.ageLimit}+';
  }
  if (age.isNotEmpty) parts.add(age);
  return parts.join('  •  ');
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.colorAccent.withValues(alpha: 0.28),
                    AppColors.colorSurface,
                  ],
                ),
                border: Border.all(color: AppColors.colorPrimaryLight.withValues(alpha: 0.7), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.colorAccent.withValues(alpha: 0.25),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: Icon(icon, size: 46, color: AppColors.colorPrimaryLight),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.meta,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? borderColor;
  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.colorInputBorder),
      ),
      child: child,
    );
    if (onTap == null) {
      return Padding(padding: margin, child: content);
    }
    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: content,
        ),
      ),
    );
  }
}

class DetailAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  const DetailAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.colorSurface,
              border: Border.all(
                color: active ? AppColors.colorPrimary : AppColors.colorInputBorder,
              ),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.colorPrimary : Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.colorPrimary : AppColors.colorTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
