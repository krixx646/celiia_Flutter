import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final bool isFocused;
  final Color glowColor;
  final Color backgroundColor;
  final Color idleBorderColor;
  final double borderRadius;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    required this.isFocused,
    required this.glowColor,
    required this.backgroundColor,
    required this.idleBorderColor,
    this.borderRadius = 999,
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    if (widget.isFocused) _controller.repeat();
  }

  @override
  void didUpdateWidget(AnimatedGradientBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFocused && !oldWidget.isFocused) {
      _controller.repeat();
    } else if (!widget.isFocused && oldWidget.isFocused) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The animated glowing border
        if (widget.isFocused)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: 0.0,
                      endAngle: math.pi * 2,
                      transform: GradientRotation(
                        _controller.value * math.pi * 2,
                      ),
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        widget.glowColor.withValues(alpha: 0.2),
                        widget.glowColor,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 0.85, 0.95, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

        // The idle border (when not focused)
        if (!widget.isFocused)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: widget.idleBorderColor, width: 1),
              ),
            ),
          ),

        // The inner content area
        Padding(
          padding: EdgeInsets.all(widget.isFocused ? 1.5 : 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
