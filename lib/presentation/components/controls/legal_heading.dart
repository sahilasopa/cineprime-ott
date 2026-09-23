import 'package:flutter/material.dart';

class LegalHeading extends StatelessWidget {
  final String text;

  const LegalHeading({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 15, color: Colors.white));
  }
}
