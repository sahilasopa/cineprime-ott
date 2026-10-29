import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/subscription_plan.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';

class MembershipPageFrame extends StatelessWidget {
  final Widget child;

  const MembershipPageFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
      child: Column(
        children: [
          const MembershipTopBar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class MembershipTopBar extends StatelessWidget {
  const MembershipTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          if (canPop)
            CircleIconButton(
              icon: Icons.arrow_back_rounded,
              size: 36,
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            const SizedBox(width: 36),
          const Expanded(
            child: Center(child: BrandMark(height: 26)),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class MembershipBody extends StatelessWidget {
  final List<SubscriptionPlan> plans;
  final SubscriptionPlan? selectedPlan;
  final ValueChanged<SubscriptionPlan> onSelect;
  final VoidCallback? onContinue;
  final Widget? promo;

  const MembershipBody({
    super.key,
    required this.plans,
    required this.selectedPlan,
    required this.onSelect,
    this.onContinue,
    this.promo,
  });

  @override
  Widget build(BuildContext context) {
    final selected = _selectedPlan(plans, selectedPlan);
    final label = selected == null || selected.buttonText.trim().isEmpty ? 'Continue' : selected.buttonText.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 460 ? 460.0 : constraints.maxWidth;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            height: constraints.maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                const Text(
                  'Membership',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'One pass. Every story.',
                  style: TextStyle(
                    color: AppColors.colorTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                const _SpecLine(),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                Expanded(
                  child: _FittedPlans(
                    plans: plans,
                    selectedId: selected?.id,
                    onSelect: onSelect,
                  ),
                ),
                if (promo != null) ...[
                  promo!,
                  const SizedBox(height: 12),
                ],
                GradientButton(
                  label: label,
                  height: 52,
                  onPressed: selected == null ? null : onContinue,
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Secure payment',
                    style: TextStyle(
                      color: AppColors.colorTextMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        behavior: HitTestBehavior.opaque,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(Icons.confirmation_number_outlined, color: AppColors.colorPrimary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Promo code',
                  style: TextStyle(
                    color: AppColors.colorTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Add',
                style: TextStyle(
                  color: AppColors.colorPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.colorSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.colorInputFill,
                    borderRadius: BorderRadius.circular(12),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => onApply(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 88,
                child: GradientButton(
                  label: 'Apply',
                  height: 44,
                  isLoading: loading,
                  onPressed: loading ? null : onApply,
                ),
              ),
            ],
          ),
          if (appliedCouponCode != null) ...[
            const SizedBox(height: 8),
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
  final String? badge;
  final bool dense;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = plan.name.isNotEmpty ? plan.name : plan.validity;
    final showOriginal = plan.originalCost != null && plan.originalCost! > plan.cost;
    final priceColor = isSelected ? AppColors.colorGold : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSelected
                ? const [Color(0xFF2C2618), Color(0xFF141820)]
                : const [Color(0xFF171E2A), Color(0xFF10151E)],
          ),
          border: Border.all(
            color: isSelected ? AppColors.colorPrimary.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mark = constraints.maxHeight.clamp(12.0, 20.0);
            final showMeta = !dense && constraints.maxHeight >= 62;
            final priceSize = constraints.maxHeight < 52 ? 16.0 : 20.0;
            return Row(
              children: [
                _SelectMark(selected: isSelected, size: mark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                height: 1,
                              ),
                            ),
                          ),
                          if (badge != null && constraints.maxHeight >= 52) ...[
                            const SizedBox(width: 8),
                            Text(
                              badge!.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.colorGold,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.9,
                                height: 1,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (showMeta) ...[
                        const SizedBox(height: 4),
                        Text(
                          plan.validity,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.colorTextMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showOriginal && showMeta)
                      Text(
                        '${plan.currency}${SubscriptionPlan.formatCost(plan.originalCost!)}',
                        style: const TextStyle(
                          color: AppColors.colorTextMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.colorTextMuted,
                          height: 1,
                        ),
                      ),
                    Text(
                      '${plan.currency}${SubscriptionPlan.formatCost(plan.cost)}',
                      style: TextStyle(
                        color: priceColor,
                        fontSize: priceSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FittedPlans extends StatelessWidget {
  final List<SubscriptionPlan> plans;
  final String? selectedId;
  final ValueChanged<SubscriptionPlan> onSelect;

  const _FittedPlans({
    required this.plans,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = plans.length;
        if (count == 0) return const SizedBox.shrink();

        const maxHeight = 84.0;
        final available = constraints.maxHeight;
        var gap = 10.0;
        var height = (available - gap * (count - 1)) / count;
        if (height > maxHeight) {
          height = maxHeight;
        } else if (height < 64) {
          gap = available < count * 48 ? 6.0 : 8.0;
          height = (available - gap * (count - 1)) / count;
        }
        if (height < 1) {
          gap = 0;
          height = available / count;
        }
        if (height < 1) height = 1;
        final used = height * count + gap * (count - 1);
        if (used > available) {
          gap = 0;
          height = available / count;
        }
        final extra = (available - (height * count + gap * (count - 1))).clamp(0.0, double.infinity);
        final dense = height < 62;

        return Padding(
          padding: EdgeInsets.only(bottom: extra),
          child: Column(
            children: [
              for (var index = 0; index < count; index++) ...[
                if (index > 0) SizedBox(height: gap),
                SizedBox(
                  height: height,
                  child: PlanCard(
                    plan: plans[index],
                    isSelected: plans[index].id == selectedId,
                    badge: _planBadge(plans[index], plans),
                    dense: dense,
                    onTap: () => onSelect(plans[index]),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SelectMark extends StatelessWidget {
  final bool selected;
  final double size;

  const _SelectMark({required this.selected, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: selected ? AppColors.primaryGradient : null,
        border: Border.all(
          color: selected ? Colors.transparent : Colors.white.withValues(alpha: 0.22),
          width: 1.4,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, color: AppColors.colorOnGold, size: size * 0.66)
          : null,
    );
  }
}

class _SpecLine extends StatelessWidget {
  const _SpecLine();

  @override
  Widget build(BuildContext context) {
    const labels = ['Weekly releases', 'Unlimited', 'Premium HD'];
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            if (index > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '·',
                  style: TextStyle(color: AppColors.colorPrimary, fontSize: 13, height: 1),
                ),
              ),
            Text(
              labels[index],
              style: const TextStyle(
                color: AppColors.colorTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

SubscriptionPlan? _selectedPlan(List<SubscriptionPlan> plans, SubscriptionPlan? current) {
  if (plans.isEmpty) return null;
  if (current == null) return plans.first;
  for (final plan in plans) {
    if (plan.id == current.id) return plan;
  }
  return plans.first;
}

String? _planBadge(SubscriptionPlan plan, List<SubscriptionPlan> plans) {
  if (plan.isMostPopular) return 'Popular';
  final bestCount = plans.where((item) => item.isBestValue).length;
  if (plan.isBestValue && bestCount > 0 && bestCount < plans.length) return 'Best value';
  return null;
}
