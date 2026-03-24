import 'dart:ui';
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
      systemNavigationBarColor: Colors.transparent,
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

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StatsScreen(),
    const ShopScreen(),
  ];

  static const _navItems = [
    _NavData(imagePath: 'assets/images/nav1.jpg', label: 'Home'),
    _NavData(imagePath: 'assets/images/nav2.jpg', label: 'Stitch'),
    _NavData(imagePath: 'assets/images/nav3.jpg', label: 'Shop'),
  ];

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/bg1.jpg'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _CozyBottomNav(
                      currentIndex: _currentIndex,
                      items: _navItems,
                      onTap: _selectTab,
                    ), 
                  ),  
                ),  
              ),  
            ),  
          ), // Closes Center
    ); // <--- ADD THE EXTRA ) AND ; HERE (Closes Outer Scaffold)
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Navigation Bar Components
// ─────────────────────────────────────────────────────────────────────────────

class _NavData {
  const _NavData({required this.imagePath, required this.label});
  final String imagePath;
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          items.length,
          (i) => _NavTab(
            data: items[i],
            isActive: i == currentIndex,
            onTap: () => onTap(i),
          ),  
        ), // List.generate
      ), // Row
      ), // Container
     ), // BackdropFilter
    ); // ClipRRect 
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

class _NavTabState extends State<_NavTab> with SingleTickerProviderStateMixin {
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
      _ctrl.forward().then((_) => _ctrl.animateBack(0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut));
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
          width: widget.isActive ? 100 : 60,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: widget.isActive ? AppTheme.softPink.withOpacity(0.35) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  widget.data.imagePath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: widget.isActive
                    ? Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.data.label,
                              style: AppTheme.captionStyle(),
                            ),
                          ),
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