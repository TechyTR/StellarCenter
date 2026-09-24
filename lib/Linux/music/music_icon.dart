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
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StellarMusicIconPainter(
          type: type,
          color: color,
        ),
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
      ..strokeWidth = size.width * 0.085
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
        size.width * .32,
        size.height * .22,
      )
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .20,
        size.width * .28,
        size.height * .28,
      )
      ..lineTo(
        size.width * .28,
        size.height * .72,
      )
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .80,
        size.width * .36,
        size.height * .75,
      )
      ..lineTo(
        size.width * .74,
        size.height * .54,
      )
      ..quadraticBezierTo(
        size.width * .81,
        size.height * .50,
        size.width * .74,
        size.height * .46,
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
          size.width * .28,
          size.height * .23,
          size.width * .14,
          size.height * .54,
        ),
        Radius.circular(size.width * .07),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .58,
          size.height * .23,
          size.width * .14,
          size.height * .54,
        ),
        Radius.circular(size.width * .07),
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
        size.width * .24,
        size.height * .28,
      )
      ..lineTo(
        size.width * .24,
        size.height * .72,
      )
      ..quadraticBezierTo(
        size.width * .24,
        size.height * .77,
        size.width * .30,
        size.height * .72,
      )
      ..lineTo(
        size.width * .62,
        size.height * .52,
      )
      ..quadraticBezierTo(
        size.width * .68,
        size.height * .50,
        size.width * .62,
        size.height * .47,
      )
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(
        size.width * .77,
        size.height * .25,
      ),
      Offset(
        size.width * .77,
        size.height * .75,
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
        size.width * .76,
        size.height * .28,
      )
      ..lineTo(
        size.width * .76,
        size.height * .72,
      )
      ..quadraticBezierTo(
        size.width * .76,
        size.height * .77,
        size.width * .70,
        size.height * .72,
      )
      ..lineTo(
        size.width * .38,
        size.height * .52,
      )
      ..quadraticBezierTo(
        size.width * .32,
        size.height * .50,
        size.width * .38,
        size.height * .47,
      )
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(
        size.width * .23,
        size.height * .25,
      ),
      Offset(
        size.width * .23,
        size.height * .75,
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
        size.width * .22,
        size.height * .40,
      )
      ..cubicTo(
        size.width * .34,
        size.height * .22,
        size.width * .61,
        size.height * .25,
        size.width * .74,
        size.height * .40,
      )
      ..lineTo(
        size.width * .82,
        size.height * .40,
      );

    canvas.drawPath(top, paint);

    final bottom = Path()
      ..moveTo(
        size.width * .78,
        size.height * .60,
      )
      ..cubicTo(
        size.width * .66,
        size.height * .78,
        size.width * .39,
        size.height * .75,
        size.width * .26,
        size.height * .60,
      )
      ..lineTo(
        size.width * .18,
        size.height * .60,
      );

    canvas.drawPath(bottom, paint);

    canvas.drawLine(
      Offset(
        size.width * .82,
        size.height * .40,
      ),
      Offset(
        size.width * .71,
        size.height * .32,
      ),
      paint,
    );

    canvas.drawLine(
      Offset(
        size.width * .82,
        size.height * .40,
      ),
      Offset(
        size.width * .71,
        size.height * .48,
      ),
      paint,
    );

    canvas.drawLine(
      Offset(
        size.width * .18,
        size.height * .60,
      ),
      Offset(
        size.width * .29,
        size.height * .52,
      ),
      paint,
    );

    canvas.drawLine(
      Offset(
        size.width * .18,
        size.height * .60,
      ),
      Offset(
        size.width * .29,
        size.height * .68,
      ),
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
