import 'package:flutter/material.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ExpandableTextWidget({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Text(
        widget.text,
        maxLines: isExpanded ? null : 4,
        style: widget.style,
        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
    );
  }
}
