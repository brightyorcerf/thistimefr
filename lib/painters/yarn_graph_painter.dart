// lib/painters/yarn_graph_painter.dart
//
// Draws a study-hours trend line that looks like thick, fuzzy pink yarn
// stitched across a felt board.  Includes fibre-texture passes and
// data-point "knot" dots.

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class YarnGraphPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  /// Animation progress 0 → 1 (line draws in from left).
  final double progress;

  const YarnGraphPainter({
    required this.values,
    required this.labels,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    const double padL = 36, padR = 16, padT = 24, padB = 44;
    final plotW = size.width - padL - padR;
    final plotH = size.height - padT - padB;

    final maxV = values.reduce(max);
    final minV = values.reduce(min);
    final range = (maxV - minV).clamp(1.0, double.infinity);

    Offset pt(int i) {
      final x = padL + (i / (values.length - 1)) * plotW;
      final y = padT + plotH - ((values[i] - minV) / range) * plotH;
      return Offset(x, y);
    }

    final allPoints = List.generate(values.length, pt);

    // Interpolate the last segment according to [progress]
    final rawCount = 2 + (progress * (values.length - 2)).floor();
    final visCount = rawCount.clamp(2, values.length);
    var visPoints = allPoints.sublist(0, visCount);

    // Partial progress on the in-flight segment
    if (visCount < values.length) {
      final frac = (progress * (values.length - 2)) % 1.0;
      final last = visPoints.last;
      final next = allPoints[visCount];
      visPoints = [...visPoints, Offset.lerp(last, next, frac)!];
    }

    // ── Y-axis grid lines ───────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = AppTheme.plumFaint.withOpacity(0.35)
      ..strokeWidth = 0.8;
    for (int i = 0; i <= 4; i++) {
      final y = padT + (i / 4) * plotH;
      canvas.drawLine(Offset(padL, y), Offset(padL + plotW, y), gridPaint);
    }

    // ── Build smooth cubic path ─────────────────────────────────────────────
    Path buildPath(List<Offset> pts, double dy) {
      final p = Path()..moveTo(pts[0].dx, pts[0].dy + dy);
      for (int i = 1; i < pts.length; i++) {
        final prev = pts[i - 1];
        final curr = pts[i];
        final cpx = (prev.dx + curr.dx) / 2;
        p.cubicTo(
          cpx, prev.dy + dy,
          cpx, curr.dy + dy,
          curr.dx, curr.dy + dy,
        );
      }
      return p;
    }

    // ── Glow aura ───────────────────────────────────────────────────────────
    canvas.drawPath(
      buildPath(visPoints, 0),
      Paint()
        ..color = AppTheme.yarnPink.withOpacity(0.22)
        ..strokeWidth = 22
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // ── Yarn passes (3 layered strokes with Y offsets) ──────────────────────
    const yarnOffsets = [-2.2, 0.0, 2.2];
    const yarnOpacities = [0.30, 0.70, 0.30];
    const yarnWidths = [6.5, 9.0, 6.5];

    for (int pass = 0; pass < 3; pass++) {
      canvas.drawPath(
        buildPath(visPoints, yarnOffsets[pass]),
        Paint()
          ..color = AppTheme.yarnPink.withOpacity(yarnOpacities[pass])
          ..strokeWidth = yarnWidths[pass]
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // ── Fibre texture ────────────────────────────────────────────────────────
    final rng = Random(42);
    final fibrePaint = Paint()
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i < visPoints.length; i++) {
      final prev = visPoints[i - 1];
      final curr = visPoints[i];
      final segments = 10;
      for (int s = 0; s <= segments; s++) {
        final t = s / segments;
        final x = prev.dx + (curr.dx - prev.dx) * t;
        final y = prev.dy + (curr.dy - prev.dy) * t;
        final angle = atan2(curr.dy - prev.dy, curr.dx - prev.dx) + pi / 2;
        final len = 2.5 + rng.nextDouble() * 3.5;
        final opacity = 0.15 + rng.nextDouble() * 0.20;
        fibrePaint.color = AppTheme.yarnPink.withOpacity(opacity);
        canvas.drawLine(
          Offset(x + cos(angle) * len, y + sin(angle) * len),
          Offset(x - cos(angle) * len, y - sin(angle) * len),
          fibrePaint,
        );
      }
    }

    // ── Knot dots ────────────────────────────────────────────────────────────
    for (int i = 0; i < visPoints.length && i < allPoints.length; i++) {
      final p = visPoints[i];
      // White ring
      canvas.drawCircle(p, 8.5,
          Paint()..color = Colors.white..style = PaintingStyle.fill);
      // Pink border
      canvas.drawCircle(p, 8.5,
          Paint()
            ..color = AppTheme.yarnPink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2);
      // Plum centre
      canvas.drawCircle(p, 4.5, Paint()..color = AppTheme.plum);
    }

    // ── X-axis labels ────────────────────────────────────────────────────────
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < min(visPoints.length, labels.length); i++) {
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: AppTheme.plum.withOpacity(0.55),
          fontSize: 10,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
        ),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(visPoints[i].dx - tp.width / 2, size.height - padB + 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant YarnGraphPainter old) =>
      old.progress != progress || old.values != values;
}
