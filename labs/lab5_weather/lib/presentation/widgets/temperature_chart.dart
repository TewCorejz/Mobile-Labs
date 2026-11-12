import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/models/daily_forecast.dart';
import '../utils/formatters.dart';

class TemperatureChart extends StatelessWidget {
  const TemperatureChart({super.key, required this.days, this.height = 150});

  final List<DailyForecast> days;
  final double height;

  static const maxColor = Color(0xFFFF9F43);
  static const minColor = Color(0xFF5DA9F0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label:
              'График температуры: '
              '${days.map((day) => '${formatWeekday(day.date)} '
                  '${formatTemperature(day.maxTemperature)}…'
                  '${formatTemperature(day.minTemperature)}').join(', ')}',
          excludeSemantics: true,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: CustomPaint(
              painter: _TemperatureChartPainter(
                maxTemperatures: [for (final day in days) day.maxTemperature],
                minTemperatures: [for (final day in days) day.minTemperature],
                pointFillColor: theme.colorScheme.surface,
                labelStyle: labelStyle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 16,
          children: [
            _LegendItem(color: maxColor, label: 'Днём'),
            _LegendItem(color: minColor, label: 'Ночью'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _TemperatureChartPainter extends CustomPainter {
  _TemperatureChartPainter({
    required this.maxTemperatures,
    required this.minTemperatures,
    required this.pointFillColor,
    required this.labelStyle,
  });

  final List<double> maxTemperatures;
  final List<double> minTemperatures;
  final Color pointFillColor;
  final TextStyle labelStyle;

  static const _verticalPadding = 24.0;
  static const _pointRadius = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final count = maxTemperatures.length;
    if (count == 0) return;

    final allValues = [...maxTemperatures, ...minTemperatures];
    final highest = allValues.reduce((a, b) => a > b ? a : b);
    final lowest = allValues.reduce((a, b) => a < b ? a : b);
    final range = highest - lowest < 1 ? 1.0 : highest - lowest;
    final chartHeight = size.height - _verticalPadding * 2;

    Offset pointAt(int index, double value) => Offset(
      size.width * (index + 0.5) / count,
      _verticalPadding + (highest - value) / range * chartHeight,
    );

    final maxPoints = [
      for (final (i, value) in maxTemperatures.indexed) pointAt(i, value),
    ];
    final minPoints = [
      for (final (i, value) in minTemperatures.indexed) pointAt(i, value),
    ];

    _drawBand(canvas, maxPoints, minPoints);
    _drawLine(canvas, maxPoints, TemperatureChart.maxColor);
    _drawLine(canvas, minPoints, TemperatureChart.minColor);
    _drawPoints(
      canvas,
      maxPoints,
      maxTemperatures,
      TemperatureChart.maxColor,
      above: true,
    );
    _drawPoints(
      canvas,
      minPoints,
      minTemperatures,
      TemperatureChart.minColor,
      above: false,
    );
  }

  void _drawBand(Canvas canvas, List<Offset> top, List<Offset> bottom) {
    final path = Path()..moveTo(top.first.dx, top.first.dy);
    _addSmoothCurve(path, top);
    path.lineTo(bottom.last.dx, bottom.last.dy);
    _addSmoothCurve(path, bottom.reversed.toList());
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          TemperatureChart.maxColor.withValues(alpha: 0.18),
          TemperatureChart.minColor.withValues(alpha: 0.18),
        ],
      ).createShader(path.getBounds());
    canvas.drawPath(path, paint);
  }

  void _drawLine(Canvas canvas, List<Offset> points, Color color) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    _addSmoothCurve(path, points);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  void _addSmoothCurve(Path path, List<Offset> points) {
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final middleX = (previous.dx + current.dx) / 2;
      path.cubicTo(
        middleX,
        previous.dy,
        middleX,
        current.dy,
        current.dx,
        current.dy,
      );
    }
  }

  void _drawPoints(
    Canvas canvas,
    List<Offset> points,
    List<double> values,
    Color color, {
    required bool above,
  }) {
    final fill = Paint()..color = pointFillColor;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (final (i, point) in points.indexed) {
      canvas
        ..drawCircle(point, _pointRadius, fill)
        ..drawCircle(point, _pointRadius, stroke);

      final label = TextPainter(
        text: TextSpan(text: formatTemperature(values[i]), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final dy = above
          ? point.dy - label.height - _pointRadius - 2
          : point.dy + _pointRadius + 2;
      label.paint(canvas, Offset(point.dx - label.width / 2, dy));
      label.dispose();
    }
  }

  @override
  bool shouldRepaint(_TemperatureChartPainter oldDelegate) =>
      !listEquals(maxTemperatures, oldDelegate.maxTemperatures) ||
      !listEquals(minTemperatures, oldDelegate.minTemperatures) ||
      pointFillColor != oldDelegate.pointFillColor ||
      labelStyle != oldDelegate.labelStyle;
}