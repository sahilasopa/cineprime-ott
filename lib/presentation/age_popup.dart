import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/platform_utils.dart';

import '../../../models/subscription_plan.dart';

/// Call this to show the styled payment + age picker dialog.
import 'dart:ui' as ui;

void showPaymentAgeDialog({
  required BuildContext context,
  required SubscriptionPlan plan,
  required void Function(int age, String? referral) onContinue,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    // so our own dim+blur is visible
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return Stack(
        children: [
          // 1) Blurs absolutely everything behind this route,
          //    including status bar, notch area, etc.
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
          ),

          // 2) Your dialog, centered on top
          Center(
            child: PaymentAgeDialog(
              plan: plan,
              onContinue: onContinue,
            ),
          ),
        ],
      );
    },
    transitionBuilder: (ctx, anim, secAnim, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: anim,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
  );
}

class PaymentAgeDialog extends StatefulWidget {
  final SubscriptionPlan plan;
  final void Function(int age, String? referral) onContinue;

  const PaymentAgeDialog({
    Key? key,
    required this.plan,
    required this.onContinue,
  }) : super(key: key);

  @override
  State<PaymentAgeDialog> createState() => _PaymentAgeDialogState();
}

class _PaymentAgeDialogState extends State<PaymentAgeDialog> {
  int? _selectedAge;
  int _selectedAgeIndex = 0;
  String? _referralCode;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight,
            ),
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                // allows Column to size naturally inside scroll
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1D1D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // header: “Payment For:” + close-button
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Payment For:',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.colorPrimary,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.close, color: Colors.black, size: 20),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // plan name & price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.plan.name,
                            style: const TextStyle(
                              color: AppColors.colorPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${widget.plan.currency}${SubscriptionPlan.formatCost(widget.plan.cost)}',
                                style: const TextStyle(
                                  color: AppColors.colorPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.plan.originalCost != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.plan.currency}${SubscriptionPlan.formatCost(widget.plan.originalCost!)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.colorPrimary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Text(
                        'Duration: ${widget.plan.validity}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),

                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[700]),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Select your age:',
                            style: const TextStyle(
                              color: AppColors.colorPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (PlatformUtils.isIOS)
                            GestureDetector(
                              onTap: () {
                                // build a list of picker entries: first a placeholder, then 18…99
                                final pickerItems = <Widget>[
                                  Center(
                                    child: Text(
                                      '---',
                                      style: TextStyle(color: Colors.grey[400], fontSize: 18),
                                    ),
                                  ),
                                  ...List.generate(82, (i) {
                                    final age = 18 + i;
                                    return Center(
                                      child: Text(
                                        age.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                    );
                                  }),
                                ];

                                // compute initial index: if no age chosen, show placeholder (0), else offset by +1
                                final initialIndex = _selectedAge != null ? (_selectedAge! - 18 + 1) : 0;

                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (_) => Container(
                                    height: 250,
                                    color: const Color(0xFF2C2C2C),
                                    child: CupertinoPicker(
                                      scrollController: FixedExtentScrollController(initialItem: initialIndex),
                                      itemExtent: 40,
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          if (index == 0) {
                                            _selectedAge = null;
                                          } else {
                                            _selectedAge = 18 + index - 1;
                                          }
                                        });
                                      },
                                      children: pickerItems,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2C),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedAge?.toString() ?? '---',
                                      style: TextStyle(
                                        color: _selectedAge == null ? Colors.grey[400] : Colors.white,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  ],
                                ),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () {
                                final initialIndex = (_selectedAge ?? 18) - 18;
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: const Color(0xFF2C2C2C),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    final controller = FixedExtentScrollController(initialItem: initialIndex);
                                    _selectedAgeIndex = initialIndex;

                                    return StatefulBuilder(
                                      builder: (context, setSheetState) {
                                        return SizedBox(
                                          height: 300,
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                height: 200,
                                                child: ListWheelScrollView.useDelegate(
                                                  controller: controller,
                                                  itemExtent: 45,
                                                  perspective: 0.005,
                                                  physics: const FixedExtentScrollPhysics(),
                                                  onSelectedItemChanged: (index) {
                                                    setSheetState(() => _selectedAgeIndex = index);
                                                    setState(() => _selectedAge = 18 + index);
                                                  },
                                                  childDelegate: ListWheelChildBuilderDelegate(
                                                    builder: (context, index) {
                                                      if (index < 0 || index >= 82) return null;
                                                      final age = 18 + index;
                                                      final isSelected = index == _selectedAgeIndex;
                                                      return GestureDetector(
                                                        onTap: () {
                                                          controller.animateToItem(
                                                            index,
                                                            duration: const Duration(milliseconds: 300),
                                                            curve: Curves.easeOut,
                                                          );
                                                          setSheetState(() => _selectedAgeIndex = index);
                                                          setState(() => _selectedAge = 18 + index);
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            '$age',
                                                            style: TextStyle(
                                                              color: isSelected ? AppColors.colorPrimary : Colors.white,
                                                              fontSize: isSelected ? 22 : 18,
                                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedAge = 18 + _selectedAgeIndex;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  'Done',
                                                  style: TextStyle(color: AppColors.colorPrimary, fontSize: 20),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2C),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedAge?.toString() ?? '---',
                                      style: TextStyle(
                                        color: _selectedAge == null ? Colors.grey[400] : Colors.white,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedAge != null
                              ? () {
                                  Navigator.of(context).pop();
                                  widget.onContinue(_selectedAge!, _referralCode);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.colorPrimary,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Continue Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReferralCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove non-alphanumeric and hyphens
    String text = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // Limit to 8 characters max (before formatting)
    text = text.toUpperCase().substring(0, text.length.clamp(0, 8));

    // Format as XXXX-XXXX
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 3 && text.length > 4) buffer.write('-');
    }

    final formatted = buffer.toString();

    // Maintain cursor position
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

void showLinkedAccountDialog(
  BuildContext context, {
  required VoidCallback onGotIt,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return Stack(
        children: [
          // 1️⃣ blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),

          // 2️⃣ dialog content
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1D),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Subscription Linked",
                        style: TextStyle(
                          color: AppColors.colorPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.colorPrimary,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.close, color: Colors.black, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    "This subscription is already linked to another account on this device. "
                    "Please log in with that account to continue using your plan.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // single large button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onGotIt();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.colorPrimary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Got it",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (ctx, anim, secAnim, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
