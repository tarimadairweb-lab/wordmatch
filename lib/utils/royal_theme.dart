import 'package:flutter/material.dart';

class RC {
  static const bg = Color(0xFF1B0A3E);
  static const panel = Color(0xFF2A1256);
  static const card = Color(0xFF32185F);
  static const cardOpen = Color(0xFF4A2080);
  static const gold = Color(0xFFFFD700);
  static const goldMid = Color(0xFFE8B020);
  static const goldDark = Color(0xFFA07010);
  static const sapphire = Color(0xFF4A9EFF);
  static const ruby = Color(0xFFFF4466);
  static const emerald = Color(0xFF22DD88);
  static const amethyst = Color(0xFFBB66FF);
  static const topaz = Color(0xFFFFAA22);
  static const white = Color(0xFFFFF8E8);
  static const muted = Color(0xFFAA99CC);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);

  static Color iconColor(String c) {
    switch (c) {
      case 'blue':
        return sapphire;
      case 'red':
        return ruby;
      case 'green':
        return emerald;
      case 'purple':
        return amethyst;
      case 'gold':
        return topaz;
      default:
        return white;
    }
  }

  static IconData iconData(String i) {
    switch (i) {
      case 'balloon':
        return Icons.circle;
      case 'box':
        return Icons.inventory_2_outlined;
      case 'star':
        return Icons.star;
      case 'diamond':
        return Icons.diamond;
      case 'heart':
        return Icons.favorite;
      default:
        return Icons.circle;
    }
  }
}

class RoyalButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  const RoyalButton({super.key, required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFA07010)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: RC.goldMid.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: RC.bg, size: 20),
              const SizedBox(width: 8)
            ],
            Text(label,
                style: TextStyle(
                    color: RC.bg, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class RoyalOutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  const RoyalOutlineButton(
      {super.key,
      required this.label,
      this.icon,
      this.onTap,
      this.color = const Color(0xFF4A9EFF)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8)
            ],
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
