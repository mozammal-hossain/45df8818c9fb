import 'package:flutter/material.dart';

/// Paints a simple line + area chart for thermal values (0–3 from backend).
class ThermalSparklinePainter extends CustomPainter {
  ThermalSparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  }) : assert(values.isNotEmpty);

  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final count = values.length;
    final maxVal = values.reduce((a, b) => a > b ? a : b).clamp(0.001, 3.0);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).clamp(0.001, 3.0);
    final stepX = count > 1 ? (size.width - 1) / (count - 1) : 0.0;

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < count; i++) {
      final x = i * stepX;
      final normalized = (values[i] - minVal) / range;
      final y = size.height - (normalized * (size.height - 2)) - 1;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo((count - 1) * stepX, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant ThermalSparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}
