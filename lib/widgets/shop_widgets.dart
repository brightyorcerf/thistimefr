// lib/widgets/shop_widgets.dart
//
// CurrencyVial  — Mason Jar (Coins) and Neon Vial (StarDust)
// ShopCharm     — An item that "hangs" from a string at the top of its container

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Currency Vials row
// ─────────────────────────────────────────────────────────────────────────────

class CurrencyVialRow extends StatelessWidget {
  const CurrencyVialRow({
    super.key,
    required this.coins,
    required this.starDust,
  });

  final int coins;
  final int starDust;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _MasonJarVial(amount: coins)),
        const SizedBox(width: 20),
        Expanded(child: _NeonVial(amount: starDust)),
      ],
    );
  }
}

// ── Mason Jar (Coins) ─────────────────────────────────────────────────────────

class _MasonJarVial extends StatefulWidget {
  const _MasonJarVial({required this.amount});
  final int amount;

  @override
  State<_MasonJarVial> createState() => _MasonJarVialState();
}

class _MasonJarVialState extends State<_MasonJarVial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.clayBox(
        color: const Color(0xFFFDF5E8),
        radius: 24,
        elevation: 0.8,
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _shimmer,
            builder: (_, __) {
              return ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.0),
                  ],
                  stops: [
                    (_shimmer.value - 0.3).clamp(0.0, 1.0),
                    _shimmer.value.clamp(0.0, 1.0),
                    (_shimmer.value + 0.3).clamp(0.0, 1.0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Image.asset('assets/images/coins.png', width: 52, height: 52, fit: BoxFit.contain),
              );
            },
          ),
          const SizedBox(height: 6),
          Text('Coins', style: AppTheme.captionStyle()),
          const SizedBox(height: 2),
          Text(
            '${widget.amount}',
            style: AppTheme.headlineStyle(size: 16),
          ),
        ],
      ),
    );
  }
}

// ── Neon Vial (StarDust) ──────────────────────────────────────────────────────

class _NeonVial extends StatelessWidget {
  const _NeonVial({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.clayBox(
        color: const Color(0xFFFDF5E8),
        radius: 24,
        elevation: 0.8,
      ),
      child: Column(
        children: [
          Image.asset('assets/images/starDust.png', width: 52, height: 52, fit: BoxFit.contain),
          const SizedBox(height: 6),
          Text('StarDust', style: AppTheme.captionStyle()),
          const SizedBox(height: 2),
          Text(
            '$amount',
            style: AppTheme.headlineStyle(size: 16),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shop Charm
// ─────────────────────────────────────────────────────────────────────────────

class ShopCharm extends StatefulWidget {
  const ShopCharm({
    super.key,
    required this.item,
    this.onBuy,
  });

  final ShopItem item;
  final VoidCallback? onBuy;

  @override
  State<ShopCharm> createState() => _ShopCharmState();
}

class _ShopCharmState extends State<ShopCharm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swing;
  late final Animation<double> _swingAnim;

  @override
  void initState() {
    super.initState();
    final phase = widget.item.emoji.codeUnitAt(0) % 1000 / 1000.0;
    _swing = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2400 + (phase * 800).toInt()),
    )..repeat(reverse: true);
    _swingAnim = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _swing, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _swing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onBuy?.call();
      },
      child: Column(
        children: [
          // Hook ring
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFB8A0A8), width: 1.5),
            ),
          ),
          // String
          Container(
            width: 1.5,
            height: 32,
            color: AppTheme.plumLight.withOpacity(0.50),
          ),
          AnimatedBuilder(
            animation: _swingAnim,
            builder: (_, child) => Transform.rotate(
              angle: _swingAnim.value,
              alignment: Alignment.topCenter,
              child: child,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.item.assetPath != null
                        ? Image.asset(widget.item.assetPath!, width: 44, height: 44)
                        : Text(widget.item.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 6),
                      Text(
                        widget.item.name,
                        style: AppTheme.bodyStyle(size: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _PriceTag(item: widget.item),
                      if (widget.item.owned)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF52B788).withOpacity(0.20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '✓ Owned',
                              style: AppTheme.captionStyle(color: const Color(0xFF2D7A57)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.item});
  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: item.currency == ShopCurrency.coins
            ? AppTheme.starDust.withOpacity(0.85)
            : AppTheme.neonVial.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.currency == ShopCurrency.coins ? '🪙' : '⚗️',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            '${item.price}',
            style: AppTheme.captionStyle(),
          ),
        ],
      ),
    );
  }
}

enum ShopCurrency { coins, starDust }

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.currency,
    this.assetPath,
    this.cardColor = const Color(0xFFFDE2E4),
    this.owned = false,
    this.description = '',
  });

  final String id;
  final String name;
  final String emoji;
  final int price;
  final ShopCurrency currency;
  final String? assetPath;
  final Color cardColor;
  final bool owned;
  final String description;
}

final kDefaultShopItems = <ShopItem>[
  const ShopItem(
    id: 'phoenix_feather',
    name: 'Phoenix Feather',
    emoji: '🪶',
    price: 80,
    currency: ShopCurrency.starDust,
    description: 'Revives your child from permadeath (once).',
  ),
  const ShopItem(
    id: 'ribbon_bow',
    name: 'Ribbon Bow',
    emoji: '🎀',
    price: 30,
    currency: ShopCurrency.coins,
    description: 'A cute bow for your mascot\'s hair.',
  ),
  const ShopItem(
    id: 'cream_cardigan',
    name: 'Cream Cardigan',
    emoji: '🧥',
    price: 60,
    currency: ShopCurrency.coins,
    description: 'Cosy knit for autumn study sessions.',
  ),
  const ShopItem(
    id: 'star_crown',
    name: 'Star Crown',
    emoji: '👑',
    price: 120,
    currency: ShopCurrency.starDust,
    description: 'Awarded to consistent scholars.',
  ),
  const ShopItem(
    id: 'healing_tea',
    name: 'Healing Tea',
    emoji: '🍵',
    price: 25,
    currency: ShopCurrency.coins,
    description: 'Restores 1 HP.',
  ),
  const ShopItem(
    id: 'sunglass_1',
    name: 'Aviator Shades',
    emoji: '🕶️',
    price: 40,
    currency: ShopCurrency.coins,
    assetPath: 'assets/images/sunglass1.png',
  ),
  const ShopItem(
    id: 'sunglass_2',
    name: 'Cat Eye Specs',
    emoji: '🕶️',
    price: 45,
    currency: ShopCurrency.coins,
    assetPath: 'assets/images/sunglass2.png',
  ),
  const ShopItem(
    id: 'sunglass_3',
    name: 'Party Glasses',
    emoji: '🕶️',
    price: 80,
    currency: ShopCurrency.starDust,
    assetPath: 'assets/images/sunglass3.png',
  ),
  const ShopItem(
    id: 'sunglass_4',
    name: 'Geek Frames',
    emoji: '🕶️',
    price: 35,
    currency: ShopCurrency.coins,
    assetPath: 'assets/images/sunglass4.png',
  ),
];