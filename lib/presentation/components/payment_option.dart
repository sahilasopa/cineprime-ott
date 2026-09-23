import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class PaymentOption extends StatelessWidget {
  final String imagePath;
  final String methodName;
  final Widget methods;
  final VoidCallback onTap;

  const PaymentOption({
    super.key,
    required this.imagePath,
    required this.methodName,
    required this.methods,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.colorSurfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.colorInputBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    methodName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  methods,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
