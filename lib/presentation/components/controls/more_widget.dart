import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cineprime/constants/colors.dart';

class MoreWidget extends StatefulWidget {
  final String text;
  final IconData? icon;
  final String? svgIconPath;
  final VoidCallback onPressed;

  const MoreWidget({
    super.key,
    required this.text,
    this.icon,
    this.svgIconPath,
    required this.onPressed,
  }) : assert(icon != null || svgIconPath != null, 'Either icon or svgIconPath must be provided');

  @override
  State<MoreWidget> createState() => _MoreWidgetState();
}

class _MoreWidgetState extends State<MoreWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.colorSurfaceElevated,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: widget.svgIconPath != null
                    ? SvgPicture.asset(
                        widget.svgIconPath!,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.colorTextMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
