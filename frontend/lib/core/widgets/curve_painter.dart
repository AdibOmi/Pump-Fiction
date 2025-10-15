import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(94.898, 1.36342);
    path_0.cubicTo(47.699, -7.03555, 0.5, 48.6077, 0.5, 48.6077);
    path_0.lineTo(0.5, 509.5);
    path_0.lineTo(201.22, 509.5);
    path_0.lineTo(392.5, 509.5);
    path_0.lineTo(392.5, 31.8096);
    path_0.lineTo(351.76, 69.08);
    path_0.cubicTo(351.76, 69.08, 315.421, 99.5831, 281.707, 99.5262);
    path_0.cubicTo(248.179, 99.4695, 230.036, 82.2033, 201.22, 60.6809);
    path_0.cubicTo(161.961, 31.359, 142.097, 9.7624, 94.898, 1.36342);
    path_0.close();

    Paint paint_0_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    paint_0_stroke.color = Colors.black;
    canvas.drawPath(path_0, paint_0_stroke);

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Colors.black;
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
