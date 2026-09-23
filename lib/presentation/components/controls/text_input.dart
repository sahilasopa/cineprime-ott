import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';

class TextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final bool isLast;
  final TextInputType textInputType;
  final String? errorText;
  final bool readOnly;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final double padding;
  final Color primaryColor;

  const TextInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.isLast,
    this.errorText,
    this.maxLength,
    this.minLines = 1,
    this.padding = 25,
    this.maxLines = 1,
    this.textInputType = TextInputType.emailAddress,
    this.readOnly = false,
    this.primaryColor = AppColors.colorPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          controller: controller,
          keyboardType: obscureText ? TextInputType.visiblePassword : textInputType,
          obscureText: obscureText,
          readOnly: readOnly,
          maxLength: maxLength,
          minLines: minLines,
          cursorColor: AppColors.colorPrimary,
          maxLines: max(1, max(minLines, maxLines)),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              borderSide: const BorderSide(color: AppColors.colorInputBorder),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              borderSide: const BorderSide(color: AppColors.colorPrimary),
            ),
            filled: true,
            fillColor: AppColors.colorInputFill,
            counterText: "",
            hintText: hintText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            errorText: errorText,
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(color: AppColors.colorHint),
          ),
          onEditingComplete: () {
            if (isLast) {
              FocusScope.of(context).unfocus();
            } else {
              FocusScope.of(context).nextFocus();
            }
          },
        ),
      ),
    );
  }
}
