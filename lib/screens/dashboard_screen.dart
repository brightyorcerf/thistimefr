// lib/screens/dashboard_screen.dart
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/squishy_button.dart';
import '../widgets/covenant_scroll.dart';
import '../widgets/mascot_pedestal.dart';

// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _hp = 3;
  String _goal = 'Study Maths Chapter 7 — Integrals & Applications';
  double _currentHours = 1.5;
  double _targetHours = 4.0;
  MascotMood _mood = MascotMood.okay;

  bool _goalCompletedToday = false;
  OverlayEntry? _overlayEntry;

  MascotMood _deriveMood() {
    final p = _targetHours > 0 ? _currentHours / _targetHours : 0.0;
    if (p >= 1.0) return MascotMood.thriving;
    if (p >= 0.5) return MascotMood.okay;
    if (p >= 0.2) return MascotMood.struggling;
    return MascotMood.danger;
  }

  void _checkWinState() {
    if (_currentHours >= _targetHours && !_goalCompletedToday) {
      _goalCompletedToday = true;
      _showWinOverlay();
    }
  }

  void _showWinOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) {
      return const _WinStarsOverlay();
    });
    overlay.insert(_overlayEntry!);
    Future.delayed(const Duration(milliseconds: 1200), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _reportBack() {
    HapticFeedback.mediumImpact();
    // TODO: connect to backend
    setState(() {
      _currentHours = (_currentHours + 0.5).clamp(0, _targetHours);
      _mood = _deriveMood();
    });
    _checkWinState();
    _showReportSheet();
  }

  void _showReportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportBackSheet(
        onConfirm: (hours) {
          Navigator.pop(context);
          setState(() {
            _currentHours = (_currentHours + hours).clamp(0, _targetHours * 2);
            _mood = _deriveMood();
          });
          _checkWinState();
        },
      ),
    );
  }

  void _editGoal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EditGoalSheet(
        currentGoal: _goal,
        targetHours: _targetHours,
        onSave: (goal, hours) {
          Navigator.pop(context);
          setState(() {
            _goal = goal;
            _targetHours = hours;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg3.jpg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildDateChip(),
                        const SizedBox(height: 24),

                        Center(
                          child: MascotPedestal(
                            mood: _mood,
                            mascotName: 'Koko',
                            diameter: 190,
                            currentHours: _currentHours,
                            targetHours: _targetHours,
                          ),
                        ),
                        const SizedBox(height: 24),

                        CovenantScroll(
                          goal: _goal,
                          currentHours: _currentHours,
                          targetHours: _targetHours,
                          onEditGoal: _editGoal,
                        ),
                        const SizedBox(height: 24),

                        _buildReportBackButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inner Child', style: AppTheme.displayStyle(size: 22)),
              Text('Your sanctuary', style: AppTheme.captionStyle()),
            ],
          ),
          const Spacer(),
          Row(
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: HeartHP(filled: i < _hp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final label = '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: AppTheme.clayBox(
            color: Colors.white.withOpacity(0.2),
            radius: 20,
            elevation: 0.5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗓️', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(label, style: AppTheme.captionStyle()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportBackButton() {
    return _ShimmerReportButton(onPressed: _reportBack);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extras
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerReportButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _ShimmerReportButton({required this.onPressed});

  @override
  State<_ShimmerReportButton> createState() => _ShimmerReportButtonState();
}

class _ShimmerReportButtonState extends State<_ShimmerReportButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SquishyButton(
      variant: SquishyVariant.jelly,
      color: AppTheme.softPink,
      borderRadius: 36,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      width: double.infinity,
      height: 72,
      onPressed: widget.onPressed,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              final val = _ctrl.value;
              return LinearGradient(
                colors: const [Colors.transparent, Colors.white24, Colors.transparent],
                stops: [val - 0.2, val, val + 0.2],
                begin: const Alignment(-1.5, 0),
                end: const Alignment(1.5, 0),
              ).createShader(bounds);
            },
            blendMode: BlendMode.plus,
            child: child,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: const Text('📖', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report Back', style: AppTheme.headlineStyle(size: 17)),
                Text(
                  'Log today\'s study session',
                  style: AppTheme.captionStyle(),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: AppTheme.plumLight),
          ],
        ),
      ),
    );
  }
}

class _WinStarsOverlay extends StatefulWidget {
  const _WinStarsOverlay();
  @override
  State<_WinStarsOverlay> createState() => _WinStarsOverlayState();
}

class _WinStarsOverlayState extends State<_WinStarsOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = Curves.easeOutCubic.transform(_ctrl.value);
          final opacity = (1.0 - _ctrl.value).clamp(0.0, 1.0);
          final size = MediaQuery.of(context).size;
          // Approximate center of the pedestal relative to viewport
          final cx = size.width / 2;
          final cy = size.height * 0.35; 
          
          return Opacity(
            opacity: opacity,
            child: Stack(
              children: List.generate(12, (i) {
                final angle = i * (pi * 2) / 12;
                final r = t * 180.0;
                return Positioned(
                  left: cx + r * cos(angle) - 15,
                  top: cy + r * sin(angle) - 15,
                  child: const Text('⭐', style: TextStyle(fontSize: 30, decoration: TextDecoration.none)),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet: Report Back
// ─────────────────────────────────────────────────────────────────────────────

class _ReportBackSheet extends StatefulWidget {
  const _ReportBackSheet({required this.onConfirm});
  final void Function(double hours) onConfirm;

  @override
  State<_ReportBackSheet> createState() => _ReportBackSheetState();
}

class _ReportBackSheetState extends State<_ReportBackSheet> {
  double _hours = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: AppTheme.clayBox(color: AppTheme.cream, radius: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.plumFaint,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          Text('How long did you study?', style: AppTheme.headlineStyle()),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SquishyButton(
                variant: SquishyVariant.ghost,
                onPressed: () => setState(() => _hours = (_hours - 0.5).clamp(0.5, 8.0)),
                child: const Text('−', style: TextStyle(fontSize: 32, color: AppTheme.plum, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Text(
                '${_hours.toStringAsFixed(1)} h',
                style: AppTheme.displayStyle(size: 32, color: AppTheme.heartRed),
              ),
              const SizedBox(width: 16),
              SquishyButton(
                variant: SquishyVariant.ghost,
                onPressed: () => setState(() => _hours = (_hours + 0.5).clamp(0.5, 8.0)),
                child: const Text('+', style: TextStyle(fontSize: 32, color: AppTheme.plum, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 32),
          SquishyButton(
            width: double.infinity,
            height: 56,
            onPressed: () => widget.onConfirm(_hours),
            child: Center(
              child: Text(
                '✓  Confirm Session',
                style: AppTheme.headlineStyle(size: 16, color: AppTheme.plum),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet: Edit Goal
// ─────────────────────────────────────────────────────────────────────────────

class _EditGoalSheet extends StatefulWidget {
  const _EditGoalSheet({
    required this.currentGoal,
    required this.targetHours,
    required this.onSave,
  });
  final String currentGoal;
  final double targetHours;
  final void Function(String goal, double hours) onSave;

  @override
  State<_EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends State<_EditGoalSheet> {
  late final TextEditingController _ctrl;
  late double _hours;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentGoal);
    _hours = widget.targetHours;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: AppTheme.clayBox(color: AppTheme.cream, radius: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.plumFaint,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(child: Text('Edit Covenant', style: AppTheme.headlineStyle())),
            const SizedBox(height: 16),
            Text('Today\'s Goal', style: AppTheme.captionStyle()),
            const SizedBox(height: 6),
            Container(
              decoration: AppTheme.clayBox(
                color: AppTheme.softPink.withOpacity(0.25),
                radius: 20,
              ),
              child: TextField(
                controller: _ctrl,
                maxLines: 2,
                style: AppTheme.bodyStyle(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Target Hours: ${_hours.toStringAsFixed(1)}h',
                style: AppTheme.captionStyle()),
            Slider(
              value: _hours,
              min: 0.5,
              max: 12.0,
              divisions: 24,
              activeColor: AppTheme.yarnPink,
              inactiveColor: AppTheme.plumFaint,
              onChanged: (v) => setState(() => _hours = v),
            ),
            const SizedBox(height: 24),
            SquishyButton(
              width: double.infinity,
              height: 56,
              onPressed: () => widget.onSave(_ctrl.text.trim(), _hours),
              child: Center(
                child: Text(
                  '📜  Seal the Covenant',
                  style: AppTheme.headlineStyle(size: 16, color: AppTheme.plum),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
