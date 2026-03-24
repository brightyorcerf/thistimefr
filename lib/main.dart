// lib/main.dart
//
// Inner Child — "Your childhood self lives on your phone."
// Entry point, system chrome config, and main navigation shell.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/shop_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFDF0D5),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const InnerChildApp());
}

class InnerChildApp extends StatelessWidget {
  const InnerChildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inner Child',
      theme: AppTheme.theme,
      home: const MainShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // Explicitly typing this as List<Widget> to satisfy the compiler
  final List<Widget> _screens = [
    const DashboardScreen(),
    const StatsScreen(),
    const ShopScreen(),
  ];

  static const _navItems = [
    _NavData(emoji: '🏠', label: 'Home'),
    _NavData(emoji: '🧵', label: 'The Stitch'),
    _NavData(emoji: '🛍️', label: 'Shop'),
  ];

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450), // Mobile Frame
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cream,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ),
      ),
      bottomNavigationBar: _CozyBottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: _selectTab,
      ),
    );
  }
} // <--- THIS was the missing bracket that broke your build!

// ─────────────────────────────────────────────────────────────────────────────
// Cozy bottom navigation bar components
// ─────────────────────────────────────────────────────────────────────────────

class _NavData {
  const _NavData({required this.emoji, required this.label});
  final String emoji;
  final String label;
}

class _CozyBottomNav extends StatelessWidget {
  const _CozyBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavData> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cream,
        border: Border(
          top: BorderSide(
            color: AppTheme.plumFaint.withOpacity(0.35),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.plum.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              items.length,
              (i) => _NavTab(
                data: items[i],
                isActive: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatefulWidget {
  const _NavTab({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  final _NavData data;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _NavTab old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.forward().then((_) {
        _ctrl.animateBack(0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: widget.isActive ? 120 : 70, // Slightly wider to fit labels
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isActive ? AppTheme.softPink : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.data.emoji,
                style: TextStyle(
                  fontSize: widget.isActive ? 20 : 22,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: widget.isActive
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          widget.data.label,
                          style: AppTheme.captionStyle(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}