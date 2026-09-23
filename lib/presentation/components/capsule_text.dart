import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';

class CapsuleText extends StatelessWidget {
  final String text;
  final bool showDot;
  final VoidCallback onPressed;

  const CapsuleText({super.key, required this.text, required this.onPressed, required this.showDot});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        alignment: Alignment.center,
        width: 100,
        height: 42,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.colorPrimary),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class CategoryCapsule extends StatelessWidget {
  final String text;
  final bool showDot;
  final VoidCallback onPressed;

  const CategoryCapsule({super.key, required this.text, required this.onPressed, required this.showDot});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        alignment: Alignment.center,
        width: 100,
        height: 43,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFff9800)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 13
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
