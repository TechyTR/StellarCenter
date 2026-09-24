import 'package:flutter/material.dart';

enum StellarMusicIconType {
  play,
  pause,
  next,
  previous,
  repeat,
}

class StellarMusicIcon extends StatelessWidget {
  final StellarMusicIconType type;
  final double size;
  final Color color;

  const StellarMusicIcon({
    super.key,
    required this.type,
    this.size = 28,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StellarMusicIconPainter(
        type: type,
        color: color,
      ),
    );
  }
}

class _StellarMusicIconPainter
    extends CustomPainter {
  final StellarMusicIconType type;
  final Color color;

  const _StellarMusicIconPainter({
    required this.type,
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (type) {
      case StellarMusicIconType.play:
        _play(canvas, size, paint);
        break;

      case StellarMusicIconType.pause:
        _pause(canvas, size, paint);
        break;

      case StellarMusicIconType.next:
        _next(canvas, size, paint);
        break;

      case StellarMusicIconType.previous:
        _previous(canvas, size, paint);
        break;

      case StellarMusicIconType.repeat:
        _repeat(canvas, size, paint);
        break;
    }
  }

  void _play(
    Canvas canvas,
    Size size,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(
        size.width * 0.34,
        size.height * 0.22,
      )
      ..lineTo(
        size.width * 0.74,
        size.height * 0.46,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.50,
        size.width * 0.74,
        size.height * 0.54,
      )
      ..lineTo(
        size.width * 0.34,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.27,
        size.height * 0.81,
        size.width * 0.27,
        size.height * 0.73,
      )
      ..lineTo(
        size.width * 0.27,
        size.height * 0.27,
      )
      ..quadraticBezierTo(
        size.width * 0.27,
        size.height * 0.19,
        size.width * 0.34,
        size.height * 0.22,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  void _pause(
    Canvas canvas,
    Size size,
    Paint paint,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.27,
          size.height * 0.22,
          size.width * 0.16,
          size.height * 0.56,
        ),
        Radius.circular(
          size.width * 0.07,
        ),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.57,
          size.height * 0.22,
          size.width * 0.16,
          size.height * 0.56,
        ),
        Radius.circular(
          size.width * 0.07,
        ),
      ),
      paint,
    );
  }

  void _next(
    Canvas canvas,
    Size size,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(
        size.width * 0.20,
        size.height * 0.28,
      )
      ..lineTo(
        size.width * 0.58,
        size.height * 0.50,
      )
      ..lineTo(
        size.width * 0.20,
        size.height * 0.72,
      )
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(
        size.width * 0.76,
        size.height * 0.24,
      ),
      Offset(
        size.width * 0.76,
        size.height * 0.76,
      ),
      paint,
    );
  }

  void _previous(
    Canvas canvas,
    Size size,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(
        size.width * 0.80,
        size.height * 0.28,
      )
      ..lineTo(
        size.width * 0.42,
        size.height * 0.50,
      )
      ..lineTo(
        size.width * 0.80,
        size.height * 0.72,
      )
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(
        size.width * 0.24,
        size.height * 0.24,
      ),
      Offset(
        size.width * 0.24,
        size.height * 0.76,
      ),
      paint,
    );
  }

  void _repeat(
    Canvas canvas,
    Size size,
    Paint paint,
  ) {
    final top = Path()
      ..moveTo(
        size.width * 0.23,
        size.height * 0.40,
      )
      ..cubicTo(
        size.width * 0.31,
        size.height * 0.24,
        size.width * 0.61,
        size.height * 0.24,
        size.width * 0.73,
        size.height * 0.40,
      )
      ..lineTo(
        size.width * 0.78,
        size.height * 0.40,
      );

    canvas.drawPath(top, paint);

    final bottom = Path()
      ..moveTo(
        size.width * 0.77,
        size.height * 0.60,
      )
      ..cubicTo(
        size.width * 0.69,
        size.height * 0.76,
        size.width * 0.39,
        size.height * 0.76,
        size.width * 0.27,
        size.height * 0.60,
      )
      ..lineTo(
        size.width * 0.22,
        size.height * 0.60,
      );

    canvas.drawPath(bottom, paint);

    final topArrow = Path()
      ..moveTo(
        size.width * 0.78,
        size.height * 0.40,
      )
      ..lineTo(
        size.width * 0.68,
        size.height * 0.32,
      )
      ..moveTo(
        size.width * 0.78,
        size.height * 0.40,
      )
      ..lineTo(
        size.width * 0.68,
        size.height * 0.48,
      );

    canvas.drawPath(topArrow, paint);

    final bottomArrow = Path()
      ..moveTo(
        size.width * 0.22,
        size.height * 0.60,
      )
      ..lineTo(
        size.width * 0.32,
        size.height * 0.52,
      )
      ..moveTo(
        size.width * 0.22,
        size.height * 0.60,
      )
      ..lineTo(
        size.width * 0.32,
        size.height * 0.68,
      );

    canvas.drawPath(
      bottomArrow,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _StellarMusicIconPainter oldDelegate,
  ) {
    return oldDelegate.type != type ||
        oldDelegate.color != color;
  }
}
