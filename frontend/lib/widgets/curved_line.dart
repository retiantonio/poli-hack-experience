import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  final Offset start;
  final Offset control;
  final Offset end;
  final Color color;
  final double strokeWidth;

  const CurvePainter({
    required this.start,
    required this.control,
    required this.end,
    this.color = Colors.black,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CurvePainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.control != control ||
        oldDelegate.end != end ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class CurvedLine extends StatelessWidget {
  final Offset start;
  final Offset control;
  final Offset end;
  final Color color;
  final double strokeWidth;
  final Size size;

  const CurvedLine({
    super.key,
    required this.start,
    required this.control,
    required this.end,
    this.color = Colors.black,
    this.strokeWidth = 4,
    this.size = const Size(300, 200),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: CurvePainter(
        start: start,
        control: control,
        end: end,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
