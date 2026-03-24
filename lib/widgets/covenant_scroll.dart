// lib/widgets/covenant_scroll.dart
//
// A "3-D parchment" widget. Tapping it "unrolls" the scroll to reveal
// the daily goal.  Uses AnimationController + custom clip for the reveal,
// with a CurvedAnimation(elasticOut) on the height expansion.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────

class CovenantScroll extends StatefulWidget {
  const CovenantScroll({
    super.key,
    required this.goal,
    required this.currentHours,
    required this.targetHours,
    this.onEditGoal,
  });

  /// Short description of today's study goal.
  final String goal;
  final double currentHours;
  final double targetHours;

  /// Called when user taps the edit button inside the scroll.
  final VoidCallback? onEditGoal;

  @override
  State<CovenantScroll> createState() => _CovenantScrollState();
}

class _CovenantScrollState extends State<CovenantScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _heightFactor;
  late final Animation<double> _rollAngle;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heightFactor = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInQuart,
    );
    _rollAngle = Tween<double>(begin: 0.0, end: -0.04).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _ctrl.forward() : _ctrl.reverse();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  double get _progress =>
      widget.targetHours > 0 ? (widget.currentHours / widget.targetHours).clamp(0.0, 1.0) : 0.0;

  Color get _progressColor {
    if (_progress >= 1.0) return const Color(0xFF52B788);
    if (_progress >= 0.5) return AppTheme.starDust;
    return AppTheme.heartRed;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Transform.rotate(
            angle: _rollAngle.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.parchment,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  ...AppTheme.clayShadow(color: const Color(0xFF7D5A3C), elevation: 0.9),
                  // Inner parchment tint
                  BoxShadow(
                    color: const Color(0xFFE8C87A).withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: -4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFB8936A).withOpacity(0.55),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Scroll top roll (always visible) ─────────────────────
                  _ScrollRoll(isTop: true),

                  // ── Collapsed header ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        const Text('📜', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isOpen ? 'Today\'s Covenant' : widget.goal,
                            style: AppTheme.headlineStyle(size: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.plumLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Expandable body ───────────────────────────────────────
                  ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: _heightFactor.value,
                      child: _ScrollBody(
                        goal: widget.goal,
                        currentHours: widget.currentHours,
                        targetHours: widget.targetHours,
                        progress: _progress,
                        progressColor: _progressColor,
                        onEditGoal: widget.onEditGoal,
                      ),
                    ),
                  ),

                  // ── Scroll bottom roll (always visible) ───────────────────
                  _ScrollRoll(isTop: false),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// The cylindrical roll at top / bottom of the parchment.
class _ScrollRoll extends StatelessWidget {
  final bool isTop;
  const _ScrollRoll({required this.isTop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD4A96A),
            const Color(0xFFBB8A50),
            const Color(0xFFD4A96A),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(18) : Radius.zero,
          bottom: isTop ? Radius.zero : const Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: Offset(0, isTop ? 2 : -2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// The expanded body content inside the scroll.
class _ScrollBody extends StatelessWidget {
  const _ScrollBody({
    required this.goal,
    required this.currentHours,
    required this.targetHours,
    required this.progress,
    required this.progressColor,
    this.onEditGoal,
  });

  final String goal;
  final double currentHours;
  final double targetHours;
  final double progress;
  final Color progressColor;
  final VoidCallback? onEditGoal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative divider line
          Row(children: [
            const Expanded(child: Divider(color: Color(0xFFB8936A), thickness: 0.8)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('✦', style: AppTheme.captionStyle(color: const Color(0xFFB8936A))),
            ),
            const Expanded(child: Divider(color: Color(0xFFB8936A), thickness: 0.8)),
          ]),
          const SizedBox(height: 12),

          // Goal text
          Text(
            goal,
            style: AppTheme.bodyStyle(size: 14),
          ),
          const SizedBox(height: 16),

          // Progress bar
          Text(
            '${currentHours.toStringAsFixed(1)} / ${targetHours.toStringAsFixed(1)} hrs',
            style: AppTheme.captionStyle(),
          ),
          const SizedBox(height: 6),
          _YarnProgressBar(progress: progress, color: progressColor),
          const SizedBox(height: 14),

          // Bottom row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusChip(progress: progress),
              if (onEditGoal != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onEditGoal!();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: AppTheme.clayBox(
                      color: AppTheme.softPink,
                      radius: 20,
                      elevation: 0.6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_rounded,
                            size: 13, color: AppTheme.plum),
                        const SizedBox(width: 5),
                        Text('Edit Goal', style: AppTheme.captionStyle()),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YarnProgressBar extends StatelessWidget {
  const _YarnProgressBar({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: AppTheme.plumFaint.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.45),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final (label, emoji) = progress >= 1.0
        ? ('Completed!', '🌟')
        : progress >= 0.5
            ? ('In Progress', '✏️')
            : ('Not Started', '😴');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.parchment,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB8936A).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text('$emoji $label', style: AppTheme.captionStyle()),
    );
  }
}
