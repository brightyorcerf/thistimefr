// lib/screens/shop_screen.dart
//
// The Inner Child Shop — items hang from strings at the top of each card,
// swaying gently.  Two currency vials track coins and star dust.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/squishy_button.dart';
import '../widgets/shop_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _coins = 240;
  int _starDust = 45;

  // Catalogue starts from defaults; owned flags are mutable
  late final List<ShopItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(kDefaultShopItems);
  }

  void _onBuy(int index) {
    final item = _items[index];
    if (item.owned) return;

    final hasEnough = item.currency == ShopCurrency.coins
        ? _coins >= item.price
        : _starDust >= item.price;

    if (!hasEnough) {
      _showInsufficientFunds(item);
      return;
    }

    _showConfirmDialog(item, index);
  }

  void _showConfirmDialog(ShopItem item, int index) {
    showDialog(
      context: context,
      builder: (_) => _PurchaseDialog(
        item: item,
        onConfirm: () {
          Navigator.pop(context);
          HapticFeedback.heavyImpact();
          setState(() {
            if (item.currency == ShopCurrency.coins) {
              _coins -= item.price;
            } else {
              _starDust -= item.price;
            }
            _items[index] = ShopItem(
              id: item.id,
              name: item.name,
              emoji: item.emoji,
              price: item.price,
              currency: item.currency,
              cardColor: item.cardColor,
              owned: true,
              description: item.description,
            );
          });
        },
      ),
    );
  }

  void _showInsufficientFunds(ShopItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.softPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(
          '😢 Not enough ${item.currency == ShopCurrency.coins ? 'Coins' : 'StarDust'}!',
          style: AppTheme.bodyStyle(),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Stack(
        children: [
          // Background: cream with faint crosshatch
          Positioned.fill(child: _ShopBackground()),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),

                // Currency vials
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CurrencyVialRow(coins: _coins, starDust: _starDust),
                ),
                const SizedBox(height: 20),

                // Tab (future: could be category filter)
                _buildCategoryRow(),
                const SizedBox(height: 12),

                // Grid
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (_, i) => ShopCharm(
                      item: _items[i],
                      onBuy: () => _onBuy(i),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The Shop', style: AppTheme.displayStyle(size: 22)),
              Text('Dress up yourself', style: AppTheme.captionStyle()),
            ],
          ),
          const Spacer(),
          SquishyButton(
            variant: SquishyVariant.clay,
            color: AppTheme.mint,
            borderRadius: 18,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪄', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text('Earn', style: AppTheme.captionStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    final categories = ['All', '👗 Outfits', '✨ Special', '🍵 Consumables'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: AppTheme.clayBox(
            color: i == 0 ? AppTheme.softPink : AppTheme.cream,
            radius: 20,
            elevation: i == 0 ? 0.6 : 0.3,
          ),
          child: Text(
            categories[i],
            style: AppTheme.captionStyle(
              color: i == 0 ? AppTheme.plum : AppTheme.plumLight,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shop background painter
// ─────────────────────────────────────────────────────────────────────────────

class _ShopBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ShopBgPainter());
  }
}

class _ShopBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFDF5E8),
    );
    final p = Paint()
      ..color = const Color(0xFFE8D8C0).withOpacity(0.35)
      ..strokeWidth = 0.6;
    const g = 18.0;
    for (double x = 0; x <= size.width; x += g) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += g) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Purchase confirmation dialog
// ─────────────────────────────────────────────────────────────────────────────

class _PurchaseDialog extends StatelessWidget {
  const _PurchaseDialog({required this.item, required this.onConfirm});

  final ShopItem item;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: AppTheme.clayBox(color: AppTheme.cream, radius: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text(item.name, style: AppTheme.headlineStyle()),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: AppTheme.bodyStyle(size: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Price row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: AppTheme.clayBox(
                color: item.currency == ShopCurrency.coins
                    ? AppTheme.starDust.withOpacity(0.70)
                    : AppTheme.neonVial.withOpacity(0.70),
                radius: 20,
                elevation: 0.5,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.currency == ShopCurrency.coins ? '🪙' : '⚗️',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.price} ${item.currency == ShopCurrency.coins ? 'Coins' : 'StarDust'}',
                    style: AppTheme.headlineStyle(size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: SquishyButton(
                    variant: SquishyVariant.clay,
                    color: AppTheme.plumFaint,
                    height: 50,
                    onPressed: () => Navigator.pop(context),
                    child: Center(
                      child: Text('Cancel', style: AppTheme.bodyStyle()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SquishyButton(
                    height: 50,
                    onPressed: onConfirm,
                    child: Center(
                      child: Text(
                        '✨ Buy!',
                        style: AppTheme.headlineStyle(size: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
