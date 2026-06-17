import 'package:flutter/material.dart';
import '../models/level_data.dart';
import '../services/game_controller.dart';
import '../utils/royal_theme.dart';

// ── KART WİDGETİ ──────────────────────────────────────────
class CardWidget extends StatefulWidget {
  final CardModel card;
  final bool isSelected;
  final VoidCallback? onTap;
  const CardWidget(
      {super.key, required this.card, required this.isSelected, this.onTap});
  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _scaleAnim = Tween(begin: 1.0, end: 0.91)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _glowAnim = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.isSelected) return RC.gold;
    switch (widget.card.state) {
      case CardState.matched:
        return RC.emerald;
      case CardState.faceUp:
        return RC.sapphire;
      default:
        return const Color(0xFF4A2880);
    }
  }

  Color get _bgColor {
    switch (widget.card.state) {
      case CardState.matched:
        return const Color(0xFF0D3320);
      case CardState.faceUp:
        return widget.isSelected
            ? const Color(0xFF3D1A6E)
            : const Color(0xFF2A1256);
      default:
        return const Color(0xFF1E0E3A);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.card.state == CardState.removed) return const SizedBox.shrink();

    final iColor = RC.iconColor(widget.card.iconColor);
    final isEN = widget.card.type == CardType.english;

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: _borderColor
                    .withOpacity(widget.card.state == CardState.matched
                        ? 0.6
                        : widget.isSelected
                            ? 0.5
                            : 0.2),
                blurRadius: widget.card.state == CardState.matched
                    ? 16
                    : widget.isSelected
                        ? 12
                        : 4,
                spreadRadius: widget.card.state == CardState.matched ? 2 : 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // Sol: Dil etiketi
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isEN
                        ? RC.sapphire.withOpacity(0.2)
                        : RC.amethyst.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isEN ? RC.sapphire : RC.amethyst,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isEN ? 'EN' : 'TR',
                      style: TextStyle(
                        color: isEN ? RC.sapphire : RC.amethyst,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Orta: Kelime
                Expanded(
                  child: Text(
                    widget.card.text,
                    style: TextStyle(
                      color: widget.card.state == CardState.matched
                          ? RC.emerald
                          : RC.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Sağ: İkon
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: iColor.withOpacity(0.6), width: 1),
                  ),
                  child: Icon(RC.iconData(widget.card.icon),
                      color: iColor, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── HEDEF BAR ─────────────────────────────────────────────
class TargetBar extends StatelessWidget {
  final List<TargetItem> targets;
  const TargetBar({super.key, required this.targets});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0A3C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RC.goldDark, width: 1.5),
        boxShadow: [
          BoxShadow(color: RC.goldDark.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: targets.map((t) {
          final c = RC.iconColor(t.iconColor);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: t.isCompleted ? c.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: t.isCompleted ? Border.all(color: c, width: 1.5) : null,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(RC.iconData(t.icon),
                  color: t.isCompleted ? c : c.withOpacity(0.4), size: 18),
              const SizedBox(width: 6),
              Text(
                'x${t.remaining}',
                style: TextStyle(
                  color: t.isCompleted ? c : RC.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (t.isCompleted) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle, color: c, size: 14),
              ],
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ── HAMLE SAYACI ──────────────────────────────────────────
class MovesCounter extends StatelessWidget {
  final int moves;
  final int maxMoves;
  const MovesCounter({super.key, required this.moves, required this.maxMoves});

  @override
  Widget build(BuildContext context) {
    final isLow = moves <= (maxMoves * 0.3).ceil();
    final c = isLow ? RC.danger : RC.gold;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.6), width: 1.5),
        boxShadow: [BoxShadow(color: c.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.bolt, color: c, size: 16),
        const SizedBox(width: 4),
        Text(
          '$moves',
          style: TextStyle(
            color: c,
            fontSize: isLow ? 20 : 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]),
    );
  }
}

// ── KONFETI PARTİKÜLÜ ─────────────────────────────────────
class _ConfettiParticle {
  double x, y, speed, size, angle;
  Color color;
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.angle,
    required this.color,
  });
}

// ── KONFETI ANİMASYONU ─────────────────────────────────────
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});
  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    final colors = [
      RC.gold,
      RC.sapphire,
      RC.emerald,
      RC.amethyst,
      RC.ruby,
      RC.topaz
    ];
    for (int i = 0; i < 80; i++) {
      _particles.add(_ConfettiParticle(
        x: (i * 37.3) % 1.0,
        y: -(i * 0.05),
        speed: 0.003 + (i % 5) * 0.001,
        size: 6 + (i % 4) * 3.0,
        angle: (i * 23.0) % 360,
        color: colors[i % colors.length],
      ));
    }
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            setState(() {
              for (final p in _particles) {
                p.y += p.speed;
                p.angle += 3;
              }
            });
          })
          ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(_particles),
        size: Size.infinite,
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.y > 1.2) continue;
      final paint = Paint()..color = p.color.withOpacity(0.85);
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.angle * 3.14159 / 180);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.5),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

// ── SONUÇ EKRANI ──────────────────────────────────────────
class ResultOverlay extends StatelessWidget {
  final GameController ctrl;
  final VoidCallback onNextLevel;
  const ResultOverlay(
      {super.key, required this.ctrl, required this.onNextLevel});

  @override
  Widget build(BuildContext context) {
    final win = ctrl.phase == GamePhase.levelSuccess;
    return Stack(
      children: [
        // Karartma
        Container(color: Colors.black.withOpacity(0.75)),

        // Konfeti (sadece kazanınca)
        if (win) const ConfettiOverlay(),

        // Dialog
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E0A3C),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: win ? RC.gold : RC.danger,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (win ? RC.gold : RC.danger).withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // İkon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: (win ? RC.gold : RC.danger).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: win ? RC.gold : RC.danger, width: 2),
                      ),
                      child: Icon(
                        win ? Icons.emoji_events : Icons.close_rounded,
                        color: win ? RC.gold : RC.danger,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      win ? 'Tebrikler!' : 'Başarısız!',
                      style: TextStyle(
                        color: win ? RC.gold : RC.danger,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      win ? 'Tüm eşleşmeleri buldun!' : 'Hamle hakkın bitti.',
                      style: const TextStyle(color: RC.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hamle: ${ctrl.totalMovesMade}',
                      style: const TextStyle(color: RC.muted, fontSize: 11),
                    ),
                    const SizedBox(height: 24),

                    if (win)
                      _RoyalBtn(
                        label: 'Sonraki Seviye',
                        icon: Icons.arrow_forward_rounded,
                        color: RC.gold,
                        textColor: const Color(0xFF1B0A3E),
                        onTap: onNextLevel,
                      )
                    else ...[
                      if (ctrl.canWatchAd)
                        _RoyalBtn(
                          label: '+5 Hamle Kazan',
                          icon: Icons.play_circle_fill,
                          color: RC.gold,
                          textColor: const Color(0xFF1B0A3E),
                          onTap: () => ctrl.watchAdForMoves(),
                        ),
                      const SizedBox(height: 10),
                      _RoyalBtn(
                        label: 'Tekrar Dene',
                        icon: Icons.replay_rounded,
                        color: RC.sapphire,
                        textColor: RC.white,
                        onTap: ctrl.restartLevel,
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Menüye Dön',
                          style: TextStyle(color: RC.muted, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoyalBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _RoyalBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.textColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
