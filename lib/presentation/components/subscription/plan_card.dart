import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/subscription_plan.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';

class PlansPageHeader extends StatelessWidget {
  final bool compact;

  const PlansPageHeader({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MEMBERSHIP',
          style: TextStyle(
            color: AppColors.colorPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
        SizedBox(height: compact ? 2 : 6),
        Text(
          'Go Premium',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 24 : 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            height: 1.05,
          ),
        ),
        SizedBox(height: compact ? 2 : 8),
        Text(
          'Bigger stories. Better entertainment.',
          style: AppTextStyles.meta.copyWith(fontSize: compact ? 13 : null),
        ),
      ],
    );
  }
}

class PromoCodeBar extends StatelessWidget {
  final bool expanded;
  final String? appliedCouponCode;
  final String? couponMessage;
  final bool loading;
  final TextEditingController controller;
  final VoidCallback onExpand;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const PromoCodeBar({
    super.key,
    required this.expanded,
    required this.appliedCouponCode,
    required this.couponMessage,
    required this.loading,
    required this.controller,
    required this.onExpand,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (!expanded && appliedCouponCode == null) {
      return GestureDetector(
        onTap: onExpand,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: const Row(
            children: [
              Icon(Icons.confirmation_number_outlined, color: AppColors.colorPrimary, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Have a promo code?',
                  style: TextStyle(
                    color: AppColors.colorTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'ADD',
                style: TextStyle(
                  color: AppColors.colorPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.colorInputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.colorInputFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.colorInputBorder),
                  ),
                  child: TextField(
                    controller: controller,
                    cursorColor: AppColors.colorPrimary,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Promo code',
                      hintStyle: TextStyle(color: AppColors.colorHint, fontSize: 15),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => onApply(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 96,
                child: GradientButton(
                  label: 'Apply',
                  height: 48,
                  isLoading: loading,
                  onPressed: loading ? null : onApply,
                ),
              ),
            ],
          ),
          if (appliedCouponCode != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.colorPrimary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    couponMessage ?? 'Promo applied',
                    style: const TextStyle(
                      color: AppColors.colorPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClear,
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      color: AppColors.colorTextSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (couponMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              couponMessage!,
              style: const TextStyle(
                color: AppColors.colorPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSubscribe;
  final List<String> features;
  final bool compact;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.onSubscribe,
    this.compact = false,
    this.features = const [
      'Weekly releases',
      'Unlimited streaming',
      'Premium HD',
    ],
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      final parts = _splitValidity(plan.validity);
      final perk = features.isNotEmpty ? features.first : plan.validity;
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? const [Color(0xFF3A2E14), Color(0xFF1A160C), Color(0xFF10222C)]
                  : const [Color(0xFF172433), Color(0xFF121820)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.colorPrimary : AppColors.colorInputBorder,
              width: isSelected ? 1.6 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.colorPrimary.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: isSelected
                      ? AppColors.primaryGradient
                      : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF245066), Color(0xFF15202C)],
                        ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _planIcon(plan.validity),
                      color: isSelected ? AppColors.colorOnGold : Colors.white,
                      size: 18,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      parts.number,
                      style: TextStyle(
                        color: isSelected ? AppColors.colorOnGold : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      parts.shortUnit,
                      style: TextStyle(
                        color: isSelected ? AppColors.colorOnGold : AppColors.colorPrimaryLight,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name.isNotEmpty ? plan.name : plan.validity,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      perk,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.colorTextSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${plan.currency}${SubscriptionPlan.formatCost(plan.cost)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: isSelected ? AppColors.colorPrimary : AppColors.colorTextMuted,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: isSelected ? _HeroPass(plan: plan, features: features, onSubscribe: onSubscribe) : _TicketPass(plan: plan),
      ),
    );
  }
}

IconData _planIcon(String validity) {
  final upper = validity.toUpperCase();
  if (upper.contains('YEAR') || upper.contains('YR')) return Icons.workspace_premium_rounded;
  if (upper.contains('MONTH')) return Icons.calendar_month_rounded;
  if (upper.contains('WEEK')) return Icons.bolt_rounded;
  return Icons.movie_filter_rounded;
}

({String number, String unit, String shortUnit}) _splitValidity(String validity) {
  final match = RegExp(r'^(\d+)\s*(.*)$').firstMatch(validity.trim());
  if (match == null || (match.group(1) ?? '').isEmpty) {
    return (number: '•', unit: validity.toUpperCase(), shortUnit: 'PASS');
  }
  final unit = (match.group(2) ?? '').trim();
  final upper = unit.toUpperCase();
  String short;
  if (upper.startsWith('MONTH')) {
    short = 'MOS';
  } else if (upper.startsWith('YEAR') || upper.startsWith('YR')) {
    short = 'YR';
  } else if (upper.startsWith('WEEK')) {
    short = 'WKS';
  } else if (upper.startsWith('DAY')) {
    short = 'DAYS';
  } else if (upper.isEmpty) {
    short = 'PASS';
  } else {
    short = upper.length <= 4 ? upper : upper.substring(0, 3);
  }
  return (number: match.group(1)!, unit: unit.isEmpty ? 'Pass' : unit, shortUnit: short);
}

class _TicketPass extends StatelessWidget {
  final SubscriptionPlan plan;

  const _TicketPass({required this.plan});

  @override
  Widget build(BuildContext context) {
    final parts = _splitValidity(plan.validity);
    const stubWidth = 78.0;

    return SizedBox(
      height: 108,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.colorSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.colorInputBorder),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: stubWidth,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.colorSurfaceElevated,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(19)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          parts.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          parts.shortUnit,
                          style: const TextStyle(
                            color: AppColors.colorPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 1,
                  height: 108,
                  child: CustomPaint(
                    painter: _DashedLinePainter(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.name.isNotEmpty ? plan.name : plan.validity,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (plan.isMostPopular)
                              const _MiniTag(label: 'HOT', color: AppColors.colorPrimary)
                            else if (plan.isBestValue)
                              const _MiniTag(label: 'VALUE', color: AppColors.colorGold),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.validity,
                          style: AppTextStyles.meta,
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (plan.originalCost != null) ...[
                              Text(
                                '${plan.currency}${SubscriptionPlan.formatCost(plan.originalCost!)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.colorTextMuted,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.colorTextMuted,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              '${plan.currency}${SubscriptionPlan.formatCost(plan.cost)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.colorTextMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: stubWidth - 8,
            top: -8,
            child: _Notch(),
          ),
          Positioned(
            left: stubWidth - 8,
            bottom: -8,
            child: _Notch(),
          ),
        ],
      ),
    );
  }
}

class _HeroPass extends StatelessWidget {
  final SubscriptionPlan plan;
  final List<String> features;
  final VoidCallback onSubscribe;

  const _HeroPass({
    required this.plan,
    required this.features,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final parts = _splitValidity(plan.validity);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorPrimary.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2A1224),
                    Color(0xFF14121C),
                    Color(0xFF1A1230),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -28,
              top: -36,
              child: Text(
                parts.number,
                style: TextStyle(
                  fontSize: 168,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: AppColors.colorPrimary.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.colorPrimaryDark.withValues(alpha: 0.28),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.colorPrimary.withValues(alpha: 0.45), width: 1.2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (plan.isMostPopular)
                        const _PassBadge(label: 'MOST POPULAR', gradient: true)
                      else if (plan.isBestValue)
                        const _PassBadge(label: 'BEST VALUE', gold: true)
                      else
                        const _PassBadge(label: 'PASS'),
                      const Spacer(),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    plan.name.isNotEmpty ? plan.name : plan.validity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        parts.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          height: 0.95,
                          letterSpacing: -2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          parts.unit.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.colorPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (plan.originalCost != null)
                            Text(
                              '${plan.currency}${SubscriptionPlan.formatCost(plan.originalCost!)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.colorTextMuted,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColors.colorTextMuted,
                              ),
                            ),
                          Text(
                            '${plan.currency}${SubscriptionPlan.formatCost(plan.cost)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 1,
                    child: CustomPaint(
                      painter: _DashedLinePainter(
                        color: Colors.white.withValues(alpha: 0.16),
                        axis: Axis.horizontal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: features.map((feature) => _FeatureChip(label: feature)).toList(),
                  ),
                  const SizedBox(height: 18),
                  GradientButton(
                    label: plan.buttonText,
                    height: 50,
                    onPressed: onSubscribe,
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

class _Notch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.colorBackground,
        border: Border.all(color: AppColors.colorInputBorder, width: 1),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _PassBadge extends StatelessWidget {
  final String label;
  final bool gradient;
  final bool gold;

  const _PassBadge({
    required this.label,
    this.gradient = false,
    this.gold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: gradient ? AppColors.primaryGradient : null,
        color: gold ? AppColors.colorGold.withValues(alpha: 0.16) : (gradient ? null : Colors.white.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(8),
        border: gold ? Border.all(color: AppColors.colorGold.withValues(alpha: 0.5)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: gold ? AppColors.colorGold : Colors.white,
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final Axis axis;

  _DashedLinePainter({
    required this.color,
    this.axis = Axis.vertical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dash = 5.0;
    const gap = 4.0;
    if (axis == Axis.vertical) {
      var y = 10.0;
      final x = size.width / 2;
      while (y < size.height - 10) {
        canvas.drawLine(Offset(x, y), Offset(x, math.min(y + dash, size.height - 10)), paint);
        y += dash + gap;
      }
    } else {
      var x = 0.0;
      final y = size.height / 2;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, size.width), y), paint);
        x += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => oldDelegate.color != color;
}
