import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(24);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6CD3F7).withOpacity(0.12),
            blurRadius: 40,
            spreadRadius: -20,
            offset: const Offset(0, 40),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: effectiveRadius,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
