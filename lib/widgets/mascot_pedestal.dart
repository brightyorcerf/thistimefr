// lib/widgets/mascot_pedestal.dart
//
// The centrepiece of the Dashboard.  A large circular "stage" with
// concentric shadow rings, a soft glow whose colour reflects the
// mascot's current mood, and a Rive animation slot.
//
// When a Rive asset is ready:
//   1. Add   rive: ^0.13.0  to pubspec.
//   2. Replace the placeholder Column with:
//        RiveAnimation.asset(
//          'assets/rive/mascot.riv',
//          stateMachines: ['MoodMachine'],
//        )

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────

enum MascotMood { thriving, okay, struggling, danger }

extension MascotMoodX on MascotMood {
  Color get glowColor {
    switch (this) {
      case MascotMood.thriving:  return const Color(0xFF52B788);
      case MascotMood.okay:      return AppTheme.starDust;
      case MascotMood.struggling:return AppTheme.yarnPink;
      case MascotMood.danger:    return AppTheme.heartRed;
    }
  }

  String get emoji {
    switch (this) {
      case MascotMood.thriving:   return '🌸';
      case MascotMood.okay:       return '🌤';
      case MascotMood.struggling: return '🌧';
      case MascotMood.danger:     return '⚡';
    }
  }

  String get label {
    switch (this) {
      case MascotMood.thriving:   return 'Thriving';
      case MascotMood.okay:       return 'Okay';
      case MascotMood.struggling: return 'Struggling';
      case MascotMood.danger:     return 'Danger';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class MascotPedestal extends StatefulWidget {
  const MascotPedestal({
    super.key,
    this.mood = MascotMood.okay,
    this.mascotName = 'Koko',
    this.diameter = 190.0,
    required this.currentHours,
    required this.targetHours,
  });

  final MascotMood mood;
  final String mascotName;
  final double diameter;
  final double currentHours;
  final double targetHours;

  @override
  State<MascotPedestal> createState() => _MascotPedestalState();
}

class _MascotPedestalState extends State<MascotPedestal>
    with TickerProviderStateMixin {
  late final AnimationController _glow;
  late final AnimationController _float;
  late final Animation<double> _glowAnim;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _glowAnim = CurvedAnimation(parent: _glow, curve: Curves.easeInOut);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _float, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glow.dispose();
    _float.dispose();
    super.dispose();
  }

  double get _progress => widget.targetHours > 0 ? (widget.currentHours / widget.targetHours).clamp(0.0, 1.0) : 0.0;
  Color get _progressColor {
    if (_progress >= 1.0) return const Color(0xFF52B788);
    if (_progress >= 0.5) return AppTheme.starDust;
    return AppTheme.heartRed;
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.diameter;
    final glow = widget.mood.glowColor;

    return SizedBox(
      width: d + 60,
      height: d + 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Outer glow ring ──────────────────────────────────────────────
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: d + 40 + _glowAnim.value * 16,
              height: d + 40 + _glowAnim.value * 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glow.withOpacity(0.22 + _glowAnim.value * 0.12),
                    blurRadius: 40 + _glowAnim.value * 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // ── Base pedestal disc ───────────────────────────────────────────
          Positioned(
            bottom: 0,
            child: Container(
              width: d * 0.75,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.plumFaint.withOpacity(0.35),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.plum.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // ── Main pedestal circle ─────────────────────────────────────────
          Container(
            width: d,
            height: d,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.cream,
                  AppTheme.softPink.withOpacity(0.55),
                ],
                stops: const [0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.plum.withOpacity(0.12),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.80),
                  blurRadius: 10,
                  spreadRadius: -4,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
          ),

          // ── Inner ring decoration / MoodRing ────────────────────────────
          SizedBox(
            width: d + 10,
            height: d + 10,
            child: CustomPaint(
              painter: MoodRingPainter(
                progress: _progress,
                progressColor: _progressColor,
              ),
            ),
          ),

          // ── Floating mascot ──────────────────────────────────────────────
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: child,
            ),
            child: SizedBox(
              width: d - 40,
              height: d - 40,
              child: _MascotPlaceholder(
                mood: widget.mood,
                name: widget.mascotName,
                size: d - 40,
              ),
            ),
          ),

          // ── Mood badge ───────────────────────────────────────────────────
          Positioned(
            bottom: 22,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: AppTheme.clayBox(
                color: glow.withOpacity(0.80),
                radius: 20,
                elevation: 0.6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.mood.emoji,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    widget.mood.label,
                    style: AppTheme.captionStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets & Painters
// ─────────────────────────────────────────────────────────────────────────────

class MoodRingPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  MoodRingPainter({required this.progress, required this.progressColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final drawRadius = size.width / 2;

    // Background track
    final trackPaint = Paint()
      ..color = const Color(0xFFE8D8D0).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawCircle(center, drawRadius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: drawRadius),
        pi / 2, // start at bottom
        progress * 2 * pi, // sweep clockwise
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MoodRingPainter old) {
    return old.progress != progress || old.progressColor != progressColor;
  }
}

class _MascotPlaceholder extends StatelessWidget {
  const _MascotPlaceholder({
    required this.mood,
    required this.name,
    required this.size,
  });

  final MascotMood mood;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final expressions = {
      MascotMood.thriving:   '(˶ᵔ ᵕ ᵔ˶)',
      MascotMood.okay:       '(• ᴗ •)',
      MascotMood.struggling: '(˚ ˃̣̣̥⌓˂̣̣̥ )',
      MascotMood.danger:     '(；д；)',
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Head
        Container(
          width: size * 0.52,
          height: size * 0.52,
          decoration: AppTheme.clayBox(
            color: const Color(0xFFE8C9A0),
            radius: size * 0.26,
            elevation: 0.8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hair bun detail
              Container(
                width: size * 0.32,
                height: size * 0.12,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4226),
                  borderRadius: BorderRadius.circular(size),
                  boxShadow: AppTheme.clayShadow(
                      color: const Color(0xFF3D2010), elevation: 0.4),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                expressions[mood]!,
                style: TextStyle(
                  fontSize: size * 0.12,
                  color: AppTheme.plum,
                  fontFamily: 'Nunito',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Body
        Container(
          width: size * 0.44,
          height: size * 0.28,
          decoration: AppTheme.clayBox(
            color: mood == MascotMood.thriving
                ? const Color(0xFFBFDDBE)
                : AppTheme.softPink,
            radius: 18,
            elevation: 0.6,
          ),
          child: Center(
            child: Text(
              name,
              style: AppTheme.captionStyle(color: AppTheme.plum),
            ),
          ),
        ),
      ],
    );
  }
}
