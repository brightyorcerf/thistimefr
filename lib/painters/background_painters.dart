// lib/painters/background_painters.dart
//
// GinghamPainter — Red-and-cream gingham with grid-paper overlay (see ref Image 2).
// FeltPainter    — Muted sage "felt board" texture for the Stats page.

import 'dart:math';
import 'package:flutter/material.dart';

// ────────────────────────────────────────────────────────────────────────────
// Gingham Background
// ────────────────────────────────────────────────────────────────────────────

class GinghamPainter extends CustomPainter {
  const GinghamPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1 · Base warm cream
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF5ECD7),
    );

    const double sq = 24.0; // size of each check

    // 2 · Horizontal red bands
    final redH = Paint()..color = const Color(0xFFB22234).withOpacity(0.30);
    for (double y = 0; y < size.height; y += sq * 2) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, sq), redH);
    }

    // 3 · Vertical red bands (same opacity → cross creates 2× overlap = darker)
    final redV = Paint()..color = const Color(0xFFB22234).withOpacity(0.30);
    for (double x = 0; x < size.width; x += sq * 2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, sq, size.height), redV);
    }

    // 4 · Grid paper overlay (fine blue-grey lines, very subtle)
    final gridPaint = Paint()
      ..color = const Color(0xFF8A9AB5).withOpacity(0.18)
      ..strokeWidth = 0.5;
    const double grid = 12.0;
    for (double x = 0; x <= size.width; x += grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += grid) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 5 · Grain / noise layer (very faint, baked in)
    final rng = Random(7);
    final grainPaint = Paint()..strokeWidth = 0.8;
    for (int i = 0; i < 400; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      grainPaint.color =
          Colors.white.withOpacity(rng.nextDouble() * 0.06);
      canvas.drawCircle(Offset(x, y), 0.6, grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ────────────────────────────────────────────────────────────────────────────
// Felt Board Background  (Stats page)
// ────────────────────────────────────────────────────────────────────────────

class FeltPainter extends CustomPainter {
  const FeltPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Base sage fill
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFD0E1DC),
    );

    final rng = Random(13);

    // Short random fibers in every direction — classic felt look
    final fiberPaint = Paint()
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 2800; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final angle = rng.nextDouble() * 2 * pi;
      final len = 4.0 + rng.nextDouble() * 6;
      final opacity = 0.06 + rng.nextDouble() * 0.10;
      fiberPaint.color = const Color(0xFF5E8070).withOpacity(opacity);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + cos(angle) * len, y + sin(angle) * len),
        fiberPaint,
      );
    }

    // Subtle vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF3A5C52).withOpacity(0.14),
        ],
        radius: 1.0,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
