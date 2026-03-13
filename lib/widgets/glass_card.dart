import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Glassmorphic card matching the CSS:
///   .glass-card {
///     background: linear-gradient(145deg, rgba(41,53,72,0.5) 0%, rgba(15,23,42,0.7) 100%);
///     border: 1px solid rgba(255,255,255,0.08);
///     transition: all 0.3s;
///   }
///   .glass-card:hover {
///     border-color: rgba(255,255,255,0.15);
///     transform: translateY(-1px);
///     box-shadow: 0 8px 30px rgba(0,0,0,0.2);
///   }
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _translateY;
  late final Animation<double> _borderAlpha;
  late final Animation<double> _shadowOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // hover: transform: translateY(-1px)
    _translateY = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    // hover: border-color from rgba(255,255,255,0.08) to rgba(255,255,255,0.15)
    _borderAlpha = Tween<double>(begin: 0.08, end: 0.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    // hover: box-shadow opacity from 0 to 0.2
    _shadowOpacity = Tween<double>(begin: 0, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent _) {
    _controller.forward();
  }

  void _onExit(PointerEvent _) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final baseBorderColor = widget.borderColor;

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // If a custom borderColor is provided, lerp its alpha up on hover.
          // Otherwise animate white alpha from 0.08 -> 0.15 per the CSS.
          final Color effectiveBorder;
          if (baseBorderColor != null) {
            effectiveBorder = Color.lerp(
              baseBorderColor.withValues(alpha: baseBorderColor.a),
              baseBorderColor.withValues(
                alpha: (baseBorderColor.a + 0.07).clamp(0.0, 1.0),
              ),
              _controller.value,
            )!;
          } else {
            effectiveBorder =
                Colors.white.withValues(alpha: _borderAlpha.value);
          }

          return Transform.translate(
            offset: Offset(0, _translateY.value),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                // hover: box-shadow: 0 8px 30px rgba(0,0,0,0.2)
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: _shadowOpacity.value),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: BackdropFilter(
                  // backdrop-filter: blur(24px)
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      // background: linear-gradient(145deg,
                      //   rgba(41,53,72,0.5) 0%, rgba(15,23,42,0.7) 100%)
                      gradient: const LinearGradient(
                        begin: Alignment(-0.57, -0.82), // ~145deg
                        end: Alignment(0.57, 0.82),
                        colors: [
                          Color.fromRGBO(41, 53, 72, 0.5),
                          Color.fromRGBO(15, 23, 42, 0.7),
                        ],
                      ),
                      // border: 1px solid rgba(255,255,255,0.08)
                      border: Border.all(color: effectiveBorder),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// KPI card with radial glow ::before effect matching the CSS:
///   .kpi-card::before {
///     content: '';
///     position: absolute;
///     top: -50%; right: -50%;
///     width: 100%; height: 100%;
///     background: radial-gradient(circle, rgba(99,102,241,0.08) 0%, transparent 70%);
///   }
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget icon;
  final String? subtitle;
  final Color? subtitleColor;
  final Color? borderColor;
  final Color? valueColor;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.subtitleColor,
    this.borderColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: borderColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : w; // fallback for unconstrained height
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ::before pseudo-element
              // top: -50%; right: -50%; width: 100%; height: 100%
              // radial-gradient(circle, rgba(99,102,241,0.08) 0%, transparent 70%)
              Positioned(
                top: -(h * 0.5),
                right: -(w * 0.5),
                width: w,
                height: h,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.7,
                        colors: [
                          Color.fromRGBO(99, 102, 241, 0.08),
                          Colors.transparent,
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              // Card content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate400,
                          letterSpacing: 1,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                        child: Center(child: icon),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: valueColor ?? Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor ?? AppColors.slate400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class ToastNotification extends StatelessWidget {
  final String title;
  final String message;
  final Color color;

  const ToastNotification({
    super.key,
    required this.title,
    required this.message,
    this.color = AppColors.success,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              Text(
                message,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
