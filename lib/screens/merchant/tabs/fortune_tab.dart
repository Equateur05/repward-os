import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confetti/confetti.dart';
import '../../../config/theme.dart';
import '../../../services/app_state.dart';
import '../../../widgets/glass_card.dart';

class FortuneTab extends StatefulWidget {
  const FortuneTab({super.key});

  @override
  State<FortuneTab> createState() => _FortuneTabState();
}

class _FortuneTabState extends State<FortuneTab> with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _glowController;
  late AnimationController _ledController;
  late AnimationController _ringGlowController;
  late ConfettiController _confettiController;
  late Animation<double> _spinAnimation;
  double _currentAngle = 0;
  bool _spinning = false;
  String? _lastWin;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _ledController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    // Golden ring brightness pulse (like HTML wheelRingGlow)
    _ringGlowController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _spinController.dispose();
    _glowController.dispose();
    _ledController.dispose();
    _ringGlowController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _spin(List<String> rewards) {
    if (_spinning || rewards.isEmpty) return;
    setState(() {
      _spinning = true;
      _lastWin = null;
    });

    final random = Random();
    final totalRotation =
        (5 + random.nextInt(4)) * 2 * pi + random.nextDouble() * 2 * pi;

    _spinAnimation = Tween<double>(
      begin: _currentAngle,
      end: _currentAngle + totalRotation,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    _spinController.reset();
    _spinController.forward().then((_) {
      final finalAngle = _spinAnimation.value % (2 * pi);
      _currentAngle = finalAngle;

      final segAngle = 2 * pi / rewards.length;
      final pointerAngle = (2 * pi - finalAngle) % (2 * pi);
      final winIndex = (pointerAngle / segAngle).floor() % rewards.length;

      setState(() {
        _spinning = false;
        _lastWin = rewards[winIndex];
      });
      _confettiController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final rewards = appState.industry.rewards;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            appState.t('fortuneTitle'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            appState.t('fortuneSubtitle'),
            style: TextStyle(fontSize: 14, color: AppColors.slate400),
          ),
          const SizedBox(height: 24),

          // Enable toggle
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                    ),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.circleNotch, size: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activer la Roue de la Fortune',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Les clients tournent la roue après un avis 5★',
                        style: TextStyle(fontSize: 12, color: AppColors.slate400),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: appState.fortuneEnabled,
                  onChanged: (v) => appState.setFortuneEnabled(v),
                  activeThumbColor: const Color(0xFFEC4899),
                  activeTrackColor: const Color(0xFFEC4899).withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ============================
          // PREMIUM FORTUNE WHEEL
          // ============================
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 380,
                  height: 400,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // === GLOW PULSE ===
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (_, __) {
                          final opacity = 0.3 + 0.3 * _glowController.value;
                          final scale = 1.0 + 0.05 * _glowController.value;
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 370,
                              height: 370,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF8B5CF6).withValues(alpha: opacity * 0.5),
                                    const Color(0xFF8B5CF6).withValues(alpha: opacity * 0.15),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // === GOLDEN OUTER RING (animated brightness like HTML wheelRingGlow) ===
                      Positioned(
                        top: 18,
                        child: AnimatedBuilder(
                          animation: _ringGlowController,
                          builder: (_, __) {
                            // Pulse brightness 1.0 → 1.2 and glow 8→20
                            final glowIntensity = 0.35 + 0.25 * _ringGlowController.value;
                            final blurAmount = 12.0 + 12.0 * _ringGlowController.value;
                            return Container(
                              width: 346,
                              height: 346,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const SweepGradient(
                                  colors: [
                                    Color(0xFFFBBF24),
                                    Color(0xFFF59E0B),
                                    Color(0xFFD97706),
                                    Color(0xFFFBBF24),
                                    Color(0xFFF59E0B),
                                    Color(0xFFD97706),
                                    Color(0xFFFBBF24),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFFBBF24).withValues(alpha: glowIntensity),
                                    blurRadius: blurAmount,
                                    spreadRadius: 2 + 2 * _ringGlowController.value,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // === DARK RING ===
                      Positioned(
                        top: 30,
                        child: Container(
                          width: 322,
                          height: 322,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0A0E1A),
                          ),
                        ),
                      ),

                      // === LED DOTS RING ===
                      Positioned(
                        top: 24,
                        child: AnimatedBuilder(
                          animation: _ledController,
                          builder: (_, __) {
                            return CustomPaint(
                              size: const Size(334, 334),
                              painter: _LedDotsPainter(
                                segmentCount: rewards.length,
                                animValue: _ledController.value,
                              ),
                            );
                          },
                        ),
                      ),

                      // === SPINNING WHEEL ===
                      Positioned(
                        top: 40,
                        child: AnimatedBuilder(
                          animation: _spinController.isAnimating
                              ? _spinAnimation
                              : _glowController,
                          builder: (_, child) {
                            final angle = _spinController.isAnimating
                                ? _spinAnimation.value
                                : _currentAngle;
                            return Transform.rotate(
                              angle: angle,
                              child: child,
                            );
                          },
                          child: CustomPaint(
                            size: const Size(300, 300),
                            painter: _PremiumWheelPainter(rewards: rewards),
                          ),
                        ),
                      ),

                      // === POINTER ===
                      Positioned(
                        top: 0,
                        child: CustomPaint(
                          size: const Size(36, 36),
                          painter: _PointerPainter(),
                        ),
                      ),

                      // === CONFETTI ===
                      Align(
                        alignment: Alignment.center,
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          shouldLoop: false,
                          numberOfParticles: 30,
                          maxBlastForce: 20,
                          minBlastForce: 8,
                          emissionFrequency: 0.05,
                          gravity: 0.2,
                          colors: const [
                            Color(0xFFFBBF24),
                            Color(0xFF8B5CF6),
                            Color(0xFFEC4899),
                            Color(0xFF10B981),
                            Color(0xFF3B82F6),
                            Color(0xFFF43F5E),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Win result
                if (_lastWin != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎉 ', style: TextStyle(fontSize: 18)),
                        Text(
                          _lastWin!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Spin button — premium gradient
                GestureDetector(
                  onTap: (appState.fortuneEnabled && !_spinning) ? () => _spin(rewards) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: (!appState.fortuneEnabled || _spinning)
                            ? [AppColors.slate700, AppColors.slate600]
                            : [
                                const Color(0xFF9333EA),
                                const Color(0xFF4F46E5),
                                const Color(0xFF9333EA),
                              ],
                      ),
                      boxShadow: (!appState.fortuneEnabled || _spinning)
                          ? []
                          : [
                              BoxShadow(
                                color: const Color(0xFF9333EA).withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          _spinning ? FontAwesomeIcons.spinner : FontAwesomeIcons.play,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _spinning ? 'Rotation...' : 'Tester la roue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Stats
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistiques de la roue',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statBox('${appState.fiveStarThisMonth}', 'Avis 5\u2605', AppColors.brandLight),
                    const SizedBox(width: 12),
                    _statBox('${appState.responsesThisMonth}', 'R\u00E9ponses IA', AppColors.success),
                    const SizedBox(width: 12),
                    _statBox(
                      appState.reviewsThisMonth > 0
                          ? '${((appState.fiveStarThisMonth / appState.reviewsThisMonth) * 100).round()}%'
                          : '0%',
                      'Taux 5\u2605',
                      AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slate400)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LED DOTS — animated ring around the wheel
// ============================================================
class _LedDotsPainter extends CustomPainter {
  final int segmentCount;
  final double animValue;

  _LedDotsPainter({required this.segmentCount, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final ledRadius = size.width / 2 - 2;
    final ledCount = segmentCount * 4;

    for (int i = 0; i < ledCount; i++) {
      final angle = (i / ledCount) * 2 * pi - pi / 2;
      final lx = cx + cos(angle) * ledRadius;
      final ly = cy + sin(angle) * ledRadius;

      final litPhase = ((i + (animValue * ledCount).round()) % 3 == 0);

      final paint = Paint()
        ..color = litPhase
            ? const Color(0xFFFBBF24)
            : const Color(0xFFFBBF24).withValues(alpha: 0.15);

      if (litPhase) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFBBF24).withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(lx, ly), 3.5, glowPaint);
      }

      canvas.drawCircle(Offset(lx, ly), 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LedDotsPainter old) =>
      old.animValue != animValue;
}

// ============================================================
// PREMIUM WHEEL PAINTER — rich gradients, shine, emojis, gemstone hub
// ============================================================
class _PremiumWheelPainter extends CustomPainter {
  final List<String> rewards;

  static const _segmentColors = [
    Color(0xFFF43F5E), // rose
    Color(0xFFF59E0B), // amber
    Color(0xFFEC4899), // pink
    Color(0xFF06B6D4), // cyan
    Color(0xFF64748B), // slate
    Color(0xFF10B981), // emerald
    Color(0xFF8B5CF6), // purple
    Color(0xFF14B8A6), // teal
    Color(0xFFEF4444), // red
    Color(0xFF3B82F6), // blue
    Color(0xFFF97316), // orange
    Color(0xFF6366F1), // indigo
  ];

  static const _icons = ['🎁', '💰', '🏷️', '☕', '🎲', '🍹', '🥂', '⭐', '🎉', '💎', '🍰', '🎀'];

  _PremiumWheelPainter({required this.rewards});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final radius = size.width / 2 - 4;
    final segCount = rewards.length;
    if (segCount == 0) return;
    final segAngle = 2 * pi / segCount;

    // === METALLIC OUTER BORDER ===
    final borderPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy - 20),
        radius + 4,
        [
          Colors.white.withValues(alpha: 0.08),
          const Color(0xFFB4B4C8).withValues(alpha: 0.15),
          const Color(0xFF646478).withValues(alpha: 0.3),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(center, radius + 3, borderPaint);

    // === SEGMENTS ===
    for (int i = 0; i < segCount; i++) {
      final baseColor = _segmentColors[i % _segmentColors.length];
      final startA = i * segAngle - pi / 2;
      final endA = (i + 1) * segAngle - pi / 2;
      final midA = (startA + endA) / 2;

      // Segment path
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius - 2),
          startA,
          segAngle,
          false,
        )
        ..close();

      // Multi-stop gradient
      final gradEnd = Offset(cx + cos(midA) * radius, cy + sin(midA) * radius);
      final segPaint = Paint()
        ..shader = ui.Gradient.linear(
          center,
          gradEnd,
          [
            baseColor.withValues(alpha: 0.33),
            baseColor.withValues(alpha: 0.73),
            baseColor,
            baseColor.withValues(alpha: 0.93),
            baseColor.withValues(alpha: 0.6),
          ],
          [0.0, 0.25, 0.5, 0.8, 1.0],
        );
      canvas.drawPath(path, segPaint);

      // Inner shine highlight (clipped)
      canvas.save();
      canvas.clipPath(path);
      final shineStart = Offset(cx + cos(startA) * 40, cy + sin(startA) * 40);
      final shineEnd = Offset(cx + cos(endA) * radius, cy + sin(endA) * radius);
      final shinePaint = Paint()
        ..shader = ui.Gradient.linear(
          shineStart,
          shineEnd,
          [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.1),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shinePaint);
      canvas.restore();

      // Gold separator lines
      final separatorPaint = Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.35)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        center,
        Offset(cx + cos(startA) * (radius - 2), cy + sin(startA) * (radius - 2)),
        separatorPaint,
      );

      // === TEXT ===
      final textAngle = startA + segAngle / 2;
      final textR = radius * 0.62;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(textAngle);

      final label = rewards[i].length > 14
          ? '${rewards[i].substring(0, 13)}…'
          : rewards[i];
      final fontSize = segCount > 8 ? 8.5 : segCount > 6 ? 9.5 : 10.5;

      // Shadow text
      final shadowTp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.7),
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      shadowTp.paint(canvas, Offset(textR - shadowTp.width / 2 + 0.8, -shadowTp.height / 2 + 0.8));

      // Main text
      final mainTp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
            shadows: const [
              Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 1)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      mainTp.paint(canvas, Offset(textR - mainTp.width / 2, -mainTp.height / 2));
      canvas.restore();

      // === EMOJI ICON ===
      final iconR = radius * 0.35;
      final ix = cx + cos(midA) * iconR;
      final iy = cy + sin(midA) * iconR;
      final iconSize = segCount > 8 ? 11.0 : 13.0;
      final iconTp = TextPainter(
        text: TextSpan(
          text: _icons[i % _icons.length],
          style: TextStyle(fontSize: iconSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      iconTp.paint(canvas, Offset(ix - iconTp.width / 2, iy - iconTp.height / 2));
    }

    // === CENTER HUB — multi-layer gemstone ===
    // Outer ring (dark)
    canvas.drawCircle(center, 30, Paint()..color = Colors.black.withValues(alpha: 0.5));

    // Hub gradient — gemstone purple
    final hubPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx - 4, cy - 4),
        24,
        [
          const Color(0xFFC4B5FD),
          const Color(0xFFA78BFA),
          const Color(0xFF7C3AED),
          const Color(0xFF4C1D95),
        ],
        [0.0, 0.3, 0.6, 1.0],
      );
    canvas.drawCircle(center, 24, hubPaint);

    // Hub ring highlight
    canvas.drawCircle(
      center,
      24,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner shine
    final hubShinePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx - 5, cy - 7),
        18,
        [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        [0.0, 0.4, 1.0],
      );
    canvas.drawCircle(center, 22, hubShinePaint);

    // Glowing gold diamond
    final diamondGlow = Paint()
      ..color = const Color(0xFFFBBF24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, 5, diamondGlow);

    final diamondTp = TextPainter(
      text: const TextSpan(
        text: '◆',
        style: TextStyle(
          color: Color(0xFFFBBF24),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    diamondTp.paint(canvas, Offset(cx - diamondTp.width / 2, cy - diamondTp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PremiumWheelPainter old) => true;
}

// ============================================================
// POINTER — golden triangle with inner highlight
// ============================================================
class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Glow shadow
    final shadowPath = Path()
      ..moveTo(centerX - 18, 0)
      ..lineTo(centerX + 18, 0)
      ..lineTo(centerX, 34)
      ..close();
    final shadowPaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(shadowPath, shadowPaint);

    // Outer triangle
    final outerPath = Path()
      ..moveTo(centerX - 18, 0)
      ..lineTo(centerX + 18, 0)
      ..lineTo(centerX, 34)
      ..close();
    final outerPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(centerX, 0),
        Offset(centerX, 34),
        [const Color(0xFFFDE68A), const Color(0xFFFBBF24)],
      );
    canvas.drawPath(outerPath, outerPaint);

    // Inner highlight
    final innerPath = Path()
      ..moveTo(centerX - 12, 2)
      ..lineTo(centerX + 12, 2)
      ..lineTo(centerX, 24)
      ..close();
    final innerPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(centerX, 2),
        Offset(centerX, 24),
        [
          Colors.white.withValues(alpha: 0.4),
          const Color(0xFFFBBF24).withValues(alpha: 0.1),
        ],
      );
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
