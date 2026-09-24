import 'package:flutter/material.dart';

import 'stellar_animation_config.dart';

class StellarPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const StellarPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<StellarPressable> createState() =>
      _StellarPressableState();
}

class _StellarPressableState
    extends State<StellarPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed
            ? StellarAnimationConfig.pressedScale
            : 1,
        duration:
            StellarAnimationConfig.button,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
