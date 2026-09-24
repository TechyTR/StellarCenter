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

class _StellarMusicIconPainter extends CustomPainter {
  final StellarMusicIconType type;
  final Color color;

  _StellarMusicIconPainter({
    required this.type,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

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
      ..moveTo(size.width * 0.35, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.20,
        size.width * 0.30,
        size.height * 0.28,
      )
      ..lineTo(
        size.width * 0.30,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.80,
        size.width * 0.37,
        size.height * 0.76,
      )
      ..lineTo(
        size.width * 0.73,
        size.height * 0.54,
      )
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.50,
        size.width * 0.73,
        size.height * 0.46,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  void _pause(
    Canvas canvas,
    Size size,
    Paint paint,
  ) {
    final left = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.28,
        size.height * 0.23,
        size.width * 0.14,
        size.height * 0.54,
      ),
      Radius.circular(size.width * 0.07),
    );

    final right = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.58,
        size.height * 0.23,
        size.width * 0.14,
        size.height * 0.54,
      ),
      Radius.circular(size.width * 0.07),
    );

    canvas.drawRRect(left, paint);
    canvas.drawRRect(right, paint);
  }

  void _next(
    Canvas canvas,
    Size size,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.28)
      ..quadraticBezierTo(
        size.width * 0.21,
        size.height * 0.24,
        size.width * 0.21,
        size.height * 0.31,
      )
      ..lineTo(size.width * 0.21, size.height * 0.69)
      ..quadraticBezierTo(
        size.width * 0.21,
        size.height * 0.76,
        size.width * 0.27,
        size.height * 0.72,
      )
      ..lineTo(size.width * 0.60, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.66,
        size.height * 0.50,
        size.width * 0.60,
        size.height * 0.47,
      )
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.75),
      paint,
    );
  }

  void _previous(
    Canvas canvas,
    Size size,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(size.width * 0.75, size.height * 0.28)
      ..quadraticBezierTo(
        size.width * 0.79,
        size.height * 0.24,
        size.width * 0.79,
        size.height * 0.31,
      )
      ..lineTo(size.width * 0.79, size.height * 0.69)
      ..quadraticBezierTo(
        size.width * 0.79,
        size.height * 0.76,
        size.width * 0.73,
        size.height * 0.72,
      )
      ..lineTo(size.width * 0.40, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.50,
        size.width * 0.40,
        size.height * 0.47,
      )
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.25),
      Offset(size.width * 0.25, size.height * 0.75),
      paint,
    );
  }

  void _repeat(
    Canvas canvas,
    Size size,
    Paint paint,
  ) {
    final path = Path();

    path.moveTo(
      size.width * 0.28,
      size.height * 0.38,
    );

    path.cubicTo(
      size.width * 0.34,
      size.height * 0.25,
      size.width * 0.57,
      size.height * 0.25,
      size.width * 0.68,
      size.height * 0.39,
    );

    path.lineTo(
      size.width * 0.78,
      size.height * 0.39,
    );

    canvas.drawPath(path, paint);

    path.reset();

    path.moveTo(
      size.width * 0.72,
      size.height * 0.62,
    );

    path.cubicTo(
      size.width * 0.66,
      size.height * 0.75,
      size.width * 0.43,
      size.height * 0.75,
      size.width * 0.32,
      size.height * 0.61,
    );

    path.lineTo(
      size.width * 0.22,
      size.height * 0.61,
    );

    canvas.drawPath(path, paint);

    final topArrow = Path()
      ..moveTo(
        size.width * 0.78,
        size.height * 0.39,
      )
      ..lineTo(
        size.width * 0.68,
        size.height * 0.31,
      )
      ..moveTo(
        size.width * 0.78,
        size.height * 0.39,
      )
      ..lineTo(
        size.width * 0.68,
        size.height * 0.47,
      );

    canvas.drawPath(topArrow, paint);

    final bottomArrow = Path()
      ..moveTo(
        size.width * 0.22,
        size.height * 0.61,
      )
      ..lineTo(
        size.width * 0.32,
        size.height * 0.53,
      )
      ..moveTo(
        size.width * 0.22,
        size.height * 0.61,
      )
      ..lineTo(
        size.width * 0.32,
        size.height * 0.69,
      );

    canvas.drawPath(bottomArrow, paint);
  }

  @override
  bool shouldRepaint(
    covariant _StellarMusicIconPainter oldDelegate,
  ) {
    return oldDelegate.type != type ||
        oldDelegate.color != color;
  }
}
