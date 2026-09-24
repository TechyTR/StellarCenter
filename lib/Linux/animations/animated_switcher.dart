import 'package:flutter/material.dart';

import 'stellar_animation_config.dart';

class StellarPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  StellarPageRoute({
    required this.page,
  }) : super(
          transitionDuration:
              StellarAnimationConfig.pageTransition,
          reverseTransitionDuration:
              StellarAnimationConfig.pageTransition,
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) {
            return page;
          },
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final offsetAnimation = Tween<Offset>(
              begin: const Offset(
                StellarAnimationConfig.pageOffset,
                0,
              ),
              end: Offset.zero,
            ).animate(curved);

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
        );
}
