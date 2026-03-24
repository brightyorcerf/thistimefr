// lib/screens/stats_screen.dart
//
// "The Stitch" — a felt-board stats page.
// • Animated yarn-line graph (draws in on mount)
// • "DIP DETECTED" red-ink stamp tooltips
// • Study log entries presented as Polaroid photos pinned to felt

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../painters/background_painters.dart';
import '../painters/yarn_graph_painter.dart';
import '../widgets/squishy_button.dart';

// ─────────────────────────────────────────────────────────────────────────────

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _graphAnim;
  late final Animation<double> _graphProgress;

  // ── Mock data (replace with backend) ──────────────────────────────────────
  static const _weekData = [2.0, 3.5, 1.0, 4.5, 0.5, 3.0, 4.0];
  static const _weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _targetHours = 4.0;

  static final _log = <_LogEntry>[
    _LogEntry(day: 'Sunday', hours: 4.0, subject: 'Physics — Waves', emoji: '🌊', isGoalMet: true),
    _LogEntry(day: 'Saturday', hours: 3.0, subject: 'Chemistry Revision', emoji: '⚗️', isGoalMet: false),
    _LogEntry(day: 'Friday', hours: 0.5, subject: 'Distracted Day 😮‍💨', emoji: '😴', isGoalMet: false, isDip: true),
    _LogEntry(day: 'Thursday', hours: 4.5, subject: 'Maths — Integrals', emoji: '∫', isGoalMet: true),
    _LogEntry(day: 'Wednesday', hours: 1.0, subject: 'Sick day 🤒', emoji: '🤒', isGoalMet: false, isDip: true),
    _LogEntry(day: 'Tuesday', hours: 3.5, subject: 'Biology Diagrams', emoji: '🧬', isGoalMet: false),
    _LogEntry(day: 'Monday', hours: 2.0, subject: 'English Literature', emoji: '📚', isGoalMet: false),
  ];

  double get _weekTotal => _weekData.reduce((a, b) => a + b);
  double get _weekAvg => _weekTotal / _weekData.length;
  int get _daysGoalMet => _weekData.where((h) => h >= _targetHours).length;

  @override
  void initState() {
    super.initState();
    _graphAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _graphProgress = CurvedAnimation(
      parent: _graphAnim,
      curve: Curves.easeOutCubic,
    );
    // Animate graph in after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _graphAnim.forward();
    });
  }

  @override
  void dispose() {
    _graphAnim.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: DotGridPainter()),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildSummaryRow(),
                        const SizedBox(height: 24),
                        _buildGraphCard(),
                        const SizedBox(height: 24),
                        _buildDipNotice(),
                        const SizedBox(height: 16),
                        Text(
                          'This Week\'s Log',
                          style: AppTheme.headlineStyle(size: 16),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(
                          _log.length,
                          (i) => _PolaroidCard(entry: _log[i], index: i),
                        ),
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The Stitch', style: AppTheme.displayStyle(size: 22)),
              Text('Your woven progress', style: AppTheme.captionStyle()),
            ],
          ),
          const Spacer(),
          SquishyButton(
            variant: SquishyVariant.clay,
            color: AppTheme.softPink,
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📅', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text('Week', style: AppTheme.captionStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _StatPill(
          label: 'Total',
          value: '${_weekTotal.toStringAsFixed(1)}h',
          emoji: '⏱️',
          color: AppTheme.softPink,
        ),
        const SizedBox(width: 10),
        _StatPill(
          label: 'Daily avg',
          value: '${_weekAvg.toStringAsFixed(1)}h',
          emoji: '📊',
          color: AppTheme.mint,
        ),
        const SizedBox(width: 10),
        _StatPill(
          label: 'Goal met',
          value: '$_daysGoalMet / 7',
          emoji: '🎯',
          color: AppTheme.starDust.withOpacity(0.75),
        ),
      ],
    );
  }

  Widget _buildGraphCard() {
    return Container(
      height: 220,
      decoration: AppTheme.clayBox(
        color: AppTheme.cream.withOpacity(0.88),
        radius: 28,
        elevation: 0.8,
      ),
      padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Row(
              children: [
                Text('Hours Studied', style: AppTheme.captionStyle()),
                const SizedBox(width: 8),
                // Legend dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.yarnPink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.yarnPink.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Text('Yarn Line', style: AppTheme.captionStyle()),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: AnimatedBuilder(
              animation: _graphProgress,
              builder: (_, __) => CustomPaint(
                painter: YarnGraphPainter(
                  values: _weekData,
                  labels: _weekLabels,
                  progress: _graphProgress.value,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDipNotice() {
    final dipDays = _log.where((e) => e.isDip).toList();
    if (dipDays.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.clayBox(
        color: AppTheme.softPink,
        radius: 24,
        elevation: 0.6,
      ),
      child: Row(
        children: [
          _DipStamp(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dips detected this week', style: AppTheme.bodyStyle(size: 13)),
                const SizedBox(height: 3),
                Text(
                  dipDays.map((e) => e.day).join(' & '),
                  style: AppTheme.captionStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small components
// ─────────────────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });
  final String label, value, emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: AppTheme.clayBox(color: color, radius: 20, elevation: 0.6),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value, style: AppTheme.headlineStyle(size: 14)),
            Text(label, style: AppTheme.captionStyle()),
          ],
        ),
      ),
    );
  }
}

// ── DIP DETECTED stamp ────────────────────────────────────────────────────────

class _DipStamp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.stampRed, width: 2.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DIP',
              style: TextStyle(
                color: AppTheme.stampRed,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                fontFamily: 'Nunito',
                letterSpacing: 3.0,
              ),
            ),
            Text(
              'DETECTED',
              style: TextStyle(
                color: AppTheme.stampRed,
                fontSize: 7,
                fontWeight: FontWeight.w900,
                fontFamily: 'Nunito',
                letterSpacing: 3.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Polaroid Card ─────────────────────────────────────────────────────────────

class _LogEntry {
  const _LogEntry({
    required this.day,
    required this.hours,
    required this.subject,
    required this.emoji,
    required this.isGoalMet,
    this.isDip = false,
  });
  final String day, subject, emoji;
  final double hours;
  final bool isGoalMet, isDip;
}

class _PolaroidCard extends StatelessWidget {
  const _PolaroidCard({required this.entry, required this.index});
  final _LogEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Deterministic left / right tilt
    final tilt = index.isEven ? 0.025 : -0.025;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Transform.rotate(
        angle: tilt,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: AppTheme.clayShadow(
                color: const Color(0xFF5C4A50), elevation: 0.7),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Column(
                children: [
                  // Photo area
                  Container(
                height: 80,
                decoration: BoxDecoration(
                  color: entry.isGoalMet
                      ? const Color(0xFFDFF5EA)
                      : entry.isDip
                          ? const Color(0xFFFFE5E5)
                          : AppTheme.softPink.withOpacity(0.45),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                ),
                child: Stack(
                  children: [
                    // Background pattern dots
                    ...List.generate(6, (i) {
                      final rng = i * 73 + entry.day.codeUnitAt(0);
                      return Positioned(
                        left: (rng % 280).toDouble(),
                        top: (rng * 3 % 60).toDouble(),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            entry.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                          if (entry.isDip) ...[
                            const SizedBox(width: 8),
                            Transform.rotate(
                              angle: -0.2,
                              child: _DipStamp(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Caption area
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.day, style: AppTheme.captionStyle()),
                          const SizedBox(height: 2),
                          Text(
                            entry.subject,
                            style: AppTheme.bodyStyle(size: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: AppTheme.clayBox(
                        color: entry.isGoalMet
                            ? const Color(0xFF52B788)
                            : AppTheme.plumFaint,
                        radius: 12,
                        elevation: 0.4,
                      ),
                      child: Text(
                        '${entry.hours.toStringAsFixed(1)}h',
                        style: AppTheme.captionStyle(
                          color: entry.isGoalMet ? Colors.white : AppTheme.plum,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Tape element
          Positioned(
            top: -5,
            child: Container(
              width: 28,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
