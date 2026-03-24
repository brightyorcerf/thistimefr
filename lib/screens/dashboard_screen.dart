// lib/screens/dashboard_screen.dart
//
// The Hero Dashboard — Gingham background, 3-heart HP header,
// floating mascot pedestal, Covenant Scroll, and jelly "Report Back" button.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../painters/background_painters.dart';
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
  // ── Local state (replace with real backend when ready) ────────────────────
  int _hp = 3;
  String _goal = 'Study Maths Chapter 7 — Integrals & Applications';
  double _currentHours = 1.5;
  double _targetHours = 4.0;
  MascotMood _mood = MascotMood.okay;

  // Derive mood from progress
  MascotMood _deriveMood() {
    final p = _targetHours > 0 ? _currentHours / _targetHours : 0.0;
    if (p >= 1.0) return MascotMood.thriving;
    if (p >= 0.5) return MascotMood.okay;
    if (p >= 0.2) return MascotMood.struggling;
    return MascotMood.danger;
  }

  void _reportBack() {
    HapticFeedback.mediumImpact();
    // TODO: connect to backend — log study session, update hours
    setState(() {
      _currentHours = (_currentHours + 0.5).clamp(0, _targetHours);
      _mood = _deriveMood();
    });
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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Gingham background ───────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: const GinghamPainter()),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildDateChip(),
                        const SizedBox(height: 24),

                        // Mascot pedestal — centrepiece
                        Center(
                          child: MascotPedestal(
                            mood: _mood,
                            mascotName: 'Koko',
                            diameter: 220,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Covenant scroll
                        CovenantScroll(
                          goal: _goal,
                          currentHours: _currentHours,
                          targetHours: _targetHours,
                          onEditGoal: _editGoal,
                        ),
                        const SizedBox(height: 20),

                        // Report Back jelly sticker button
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

  // ─── Sub-builders ─────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inner Child', style: AppTheme.displayStyle(size: 22)),
              Text(
                'Your sanctuary',
                style: AppTheme.captionStyle(),
              ),
            ],
          ),
          const Spacer(),

          // HP Hearts
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
    final label =
        '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: AppTheme.clayBox(
        color: AppTheme.cream.withOpacity(0.85),
        radius: 20,
        elevation: 0.5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🗓️', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: AppTheme.captionStyle()),
        ],
      ),
    );
  }

  Widget _buildReportBackButton() {
    return SquishyButton(
      variant: SquishyVariant.jelly,
      color: AppTheme.softPink,
      borderRadius: 36,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      width: double.infinity,
      height: 64,
      onPressed: _reportBack,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Translucent sticker border feel
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
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 15, color: AppTheme.plumLight),
        ],
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
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.plumFaint,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Text('How long did you study?', style: AppTheme.headlineStyle()),
          const SizedBox(height: 6),
          Text(
            '${_hours.toStringAsFixed(1)} hours',
            style: AppTheme.displayStyle(size: 32, color: AppTheme.heartRed),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _hours,
            min: 0.5,
            max: 8.0,
            divisions: 15,
            activeColor: AppTheme.yarnPink,
            inactiveColor: AppTheme.plumFaint,
            onChanged: (v) => setState(() => _hours = v),
          ),
          const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            Center(child: Text('Edit Covenant', style: AppTheme.headlineStyle())),
            const SizedBox(height: 16),
            Text('Today\'s Goal', style: AppTheme.captionStyle()),
            const SizedBox(height: 6),
            TextField(
              controller: _ctrl,
              maxLines: 2,
              style: AppTheme.bodyStyle(),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.softPink.withOpacity(0.30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            Text('Target Hours: ${_hours.toStringAsFixed(1)}h',
                style: AppTheme.captionStyle()),
            Slider(
              value: _hours,
              min: 0.5,
              max: 12.0,
              divisions: 23,
              activeColor: AppTheme.yarnPink,
              inactiveColor: AppTheme.plumFaint,
              onChanged: (v) => setState(() => _hours = v),
            ),
            const SizedBox(height: 16),
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
