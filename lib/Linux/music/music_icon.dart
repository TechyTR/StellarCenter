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
        painter: _MusicIconPainter(
          type: type,
          color: color,
        ),
      ),
    );
  }
}

class _MusicIconPainter extends CustomPainter {
  final StellarMusicIconType type;
  final Color color;

  const _MusicIconPainter({
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
    Size s,
    Paint p,
  ) {
    final path = Path()
      ..moveTo(s.width * .30, s.height * .20)
      ..lineTo(s.width * .76, s.height * .50)
      ..lineTo(s.width * .30, s.height * .80)
      ..close();

    canvas.drawPath(path, p);
  }

  void _pause(
    Canvas canvas,
    Size s,
    Paint p,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * .25,
          s.height * .20,
          s.width * .17,
          s.height * .60,
        ),
        Radius.circular(s.width * .06),
      ),
      p,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * .58,
          s.height * .20,
          s.width * .17,
          s.height * .60,
        ),
        Radius.circular(s.width * .06),
      ),
      p,
    );
  }

  void _next(
    Canvas canvas,
    Size s,
    Paint p,
  ) {
    final path = Path()
      ..moveTo(s.width * .18, s.height * .25)
      ..lineTo(s.width * .57, s.height * .50)
      ..lineTo(s.width * .18, s.height * .75)
      ..close();

    canvas.drawPath(path, p);

    canvas.drawLine(
      Offset(s.width * .78, s.height * .22),
      Offset(s.width * .78, s.height * .78),
      p,
    );
  }

  void _previous(
    Canvas canvas,
    Size s,
    Paint p,
  ) {
    final path = Path()
      ..moveTo(s.width * .82, s.height * .25)
      ..lineTo(s.width * .43, s.height * .50)
      ..lineTo(s.width * .82, s.height * .75)
      ..close();

    canvas.drawPath(path, p);

    canvas.drawLine(
      Offset(s.width * .22, s.height * .22),
      Offset(s.width * .22, s.height * .78),
      p,
    );
  }

  void _repeat(
    Canvas canvas,
    Size s,
    Paint p,
  ) {
    final path = Path()
      ..moveTo(s.width * .22, s.height * .40)
      ..cubicTo(
        s.width * .34,
        s.height * .20,
        s.width * .66,
        s.height * .20,
        s.width * .78,
        s.height * .40,
      )
      ..moveTo(s.width * .78, s.height * .60)
      ..cubicTo(
        s.width * .66,
        s.height * .80,
        s.width * .34,
        s.height * .80,
        s.width * .22,
        s.height * .60,
      );

    canvas.drawPath(path, p);

    canvas.drawLine(
      Offset(s.width * .78, s.height * .40),
      Offset(s.width * .67, s.height * .33),
      p,
    );

    canvas.drawLine(
      Offset(s.width * .78, s.height * .40),
      Offset(s.width * .68, s.height * .49),
      p,
    );

    canvas.drawLine(
      Offset(s.width * .22, s.height * .60),
      Offset(s.width * .32, s.height * .51),
      p,
    );

    canvas.drawLine(
      Offset(s.width * .22, s.height * .60),
      Offset(s.width * .33, s.height * .68),
      p,
    );
  }

  @override
  bool shouldRepaint(
    covariant _MusicIconPainter oldDelegate,
  ) {
    return oldDelegate.type != type ||
        oldDelegate.color != color;
  }
}
