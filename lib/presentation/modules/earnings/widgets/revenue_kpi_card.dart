import 'package:flutter/material.dart';

class RevenueKpiCard extends StatefulWidget {
  final String title;
  final double amount;
  final String currency;
  final String caption;
  final IconData icon;
  final bool isDelivered;
  final Gradient gradient;
  final Color shadowColor;

  const RevenueKpiCard({
    super.key,
    required this.title,
    required this.amount,
    this.currency = 'NLe',
    required this.caption,
    required this.icon,
    required this.isDelivered,
    required this.gradient,
    required this.shadowColor,
  });

  factory RevenueKpiCard.delivered({
    Key? key,
    required double amount,
    int count = 0,
    String currency = 'NLe',
  }) {
    final countText = '$count Completed Deliver${count == 1 ? 'y' : 'ies'}';
    return RevenueKpiCard(
      key: key,
      title: 'Total Delivered Revenue',
      amount: amount,
      currency: currency,
      caption: countText,
      icon: Icons.account_balance_wallet_rounded,
      isDelivered: true,
      gradient: const LinearGradient(
        colors: [Color(0xFF0D7A4A), Color(0xFF16A34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0x3316A34A),
    );
  }

  factory RevenueKpiCard.inProgress({
    Key? key,
    required double amount,
    int count = 0,
    String currency = 'NLe',
  }) {
    final countText = '$count Active In-Transit Drop${count == 1 ? '' : 's'}';
    return RevenueKpiCard(
      key: key,
      title: 'In-Progress Potential',
      amount: amount,
      currency: currency,
      caption: countText,
      icon: Icons.local_shipping_rounded,
      isDelivered: false,
      gradient: const LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0x332563EB),
    );
  }

  @override
  State<RevenueKpiCard> createState() => _RevenueKpiCardState();
}

class _RevenueKpiCardState extends State<RevenueKpiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
    if (value % 1 == 0) {
      final parts = value.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '${widget.currency} $parts';
    } else {
      final whole = value.truncate();
      final decimals = ((value - whole).abs() * 100).round().toString().padLeft(2, '0');
      final parts = whole.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '${widget.currency} $parts.$decimals';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(widget.amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (widget.isDelivered)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF16A34A),
                    size: 13,
                  ),
                )
              else
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.lightBlueAccent.withAlpha(180),
                            blurRadius: 6 * _pulseAnimation.value,
                            spreadRadius: 2 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  widget.caption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
