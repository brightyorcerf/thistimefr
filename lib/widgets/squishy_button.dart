// lib/widgets/squishy_button.dart
//
// Every tap feels like squishing a soft plushie:
//   • Tap-down  → quick scale-compress (easeOut, 120 ms)
//   • Tap-up    → bouncy spring back via elasticOut (500 ms)
//   • Haptic    → HapticFeedback.lightImpact on press

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────

enum SquishyVariant {
  /// Matte clay pill / card shape (default)
  clay,

  /// Translucent "jelly sticker" — frosted glass look
  jelly,

  /// Borderless, for icon-only interactions
  ghost,
}

// ─────────────────────────────────────────────────────────────────────────────

class SquishyButton extends StatefulWidget {
  const SquishyButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.variant = SquishyVariant.clay,
    this.padding,
    this.borderRadius,
    this.width,
    this.height,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final SquishyVariant variant;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? width;
  final double? height;

  @override
  State<SquishyButton> createState() => _SquishyButtonState();
}

class _SquishyButtonState extends State<SquishyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _scale;

  static const _compressDuration = Duration(milliseconds: 110);
  static const _releaseDuration  = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _releaseDuration);
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _compress() async {
    HapticFeedback.lightImpact();
    await _ctrl.animateTo(
      1.0,
      duration: _compressDuration,
      curve: Curves.easeOut,
    );
  }

  Future<void> _bounce() async {
    widget.onPressed?.call();
    await _ctrl.animateBack(
      0.0,
      duration: _releaseDuration,
      curve: Curves.elasticOut,
    );
  }

  // ─── Visual layers ─────────────────────────────────────────────────────────

  Decoration _decoration(bool isPressed) {
    final r = widget.borderRadius ?? 32.0;
    switch (widget.variant) {
      case SquishyVariant.clay:
        return AppTheme.clayBox(
          color: widget.color ?? AppTheme.softPink,
          radius: r,
          elevation: isPressed ? 0.4 : 1.0,
        );

      case SquishyVariant.jelly:
        return BoxDecoration(
          color: (widget.color ?? AppTheme.softPink).withOpacity(0.55),
          borderRadius: BorderRadius.circular(r),
          border: Border.all(
            color: Colors.white.withOpacity(0.70),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.color ?? AppTheme.softPink).withOpacity(0.35),
              blurRadius: 16,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case SquishyVariant.ghost:
        return const BoxDecoration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _compress(),
      onTapUp: (_) => _bounce(),
      onTapCancel: () => _ctrl.animateBack(
        0.0,
        duration: _releaseDuration,
        curve: Curves.elasticOut,
      ),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          // Derive scale: 1.0 → 0.88 → spring back past 1.0 (elasticOut overshoot)
          final rawScale = _scale.value;
          return Transform.scale(
            scale: rawScale,
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) => Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: _decoration(_ctrl.value > 0.1),
            child: child,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Convenience: Heart HP button (clay red heart that beats on tap)
// ─────────────────────────────────────────────────────────────────────────────

class HeartHP extends StatelessWidget {
  const HeartHP({super.key, required this.filled, this.size = 28});

  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: filled
          ? AppTheme.clayBox(
              color: AppTheme.heartRed,
              radius: size * 0.5,
              elevation: 0.8,
            )
          : BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4B8BC), width: 1.5),
            ),
      child: Center(
        child: filled ? Text('❤️', style: TextStyle(fontSize: size * 0.52)) : const SizedBox.shrink(),
      ),
    );
  }
}
