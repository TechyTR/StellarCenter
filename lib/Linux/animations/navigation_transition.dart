import 'package:flutter/material.dart';

class StellarNavigationTransition extends StatelessWidget {
  final int currentIndex;
  final int itemCount;

  const StellarNavigationTransition({
    super.key,
    required this.currentIndex,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            constraints.maxWidth / itemCount;

        return AnimatedAlign(
          duration:
              const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment(
            -1 +
                (currentIndex *
                    2 /
                    (itemCount - 1)),
            0,
          ),
          child: Container(
            width: itemWidth * .58,
            height: 4,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(20),
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),
        );
      },
    );
  }
}
