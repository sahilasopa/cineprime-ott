import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final Icon icon;
  final Text text;

  const IconText({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        icon,
        const SizedBox(width: 8),
        text
      ],
    );
  }
}
