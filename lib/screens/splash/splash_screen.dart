import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _exitController;

  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<double> _iconRotation;
  late Animation<double> _glowRadius;
  late Animation<double> _glowOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Generate particles
    for (int i = 0; i < 30; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 4 + 1,
        speed: _random.nextDouble() * 0.3 + 0.1,
        opacity: _random.nextDouble() * 0.6 + 0.1,
        delay: _random.nextDouble() * 0.5,
      ));
    }

    // Icon animation: scale up with elastic bounce + rotate slightly
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _iconRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Glow pulsing animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowRadius = Tween<double>(begin: 40.0, end: 80.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Exit animation
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    _exitScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Phase 1: Icon appears (0ms)
    await Future.delayed(const Duration(milliseconds: 200));
    _iconController.forward();
    _particleController.repeat();

    // Phase 2: Glow starts pulsing (600ms)
    await Future.delayed(const Duration(milliseconds: 600));
    _glowController.repeat(reverse: true);

    // Phase 3: Text appears (1000ms)
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();

    // Phase 4: Hold for a moment, then exit (2500ms total)
    await Future.delayed(const Duration(milliseconds: 1500));
    _exitController.forward();

    // Phase 5: Complete
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onComplete();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _iconController,
        _glowController,
        _textController,
        _particleController,
        _exitController,
      ]),
      builder: (context, _) {
        return Opacity(
          opacity: _exitOpacity.value,
          child: Transform.scale(
            scale: _exitScale.value,
            child: Scaffold(
              backgroundColor: AppColors.slate950,
              body: Stack(
                children: [
                  // Gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.2),
                        radius: 1.2,
                        colors: [
                          Color(0xFF1A1040),
                          Color(0xFF0D0D1A),
                          AppColors.slate950,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),

                  // Floating particles
                  ..._particles.map((p) => _buildParticle(p)),

                  // Center content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon with glow
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow
                            Container(
                              width: _glowRadius.value * 4,
                              height: _glowRadius.value * 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brand.withValues(
                                      alpha: _glowOpacity.value * 0.3,
                                    ),
                                    blurRadius: _glowRadius.value * 2,
                                    spreadRadius: _glowRadius.value * 0.5,
                                  ),
                                ],
                              ),
                            ),

                            // Inner glow ring
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.brandLight.withValues(
                                    alpha: _glowOpacity.value * 0.2,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),

                            // The icon
                            Opacity(
                              opacity: _iconOpacity.value,
                              child: Transform.scale(
                                scale: _iconScale.value,
                                child: Transform.rotate(
                                  angle: _iconRotation.value,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.brand.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Image.asset(
                                        'asset/icon.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // App name
                        SlideTransition(
                          position: _textSlide,
                          child: Opacity(
                            opacity: _textOpacity.value,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFFE0E7FF),
                                  AppColors.brandLight,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Text(
                                'Repward',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        SlideTransition(
                          position: _subtitleSlide,
                          child: Opacity(
                            opacity: _subtitleOpacity.value,
                            child: Text(
                              'Réputation Intelligente',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.slate400,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom shimmer line
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: _subtitleOpacity.value * 0.5,
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.brandLight,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticle(_Particle p) {
    final progress = (_particleController.value + p.delay) % 1.0;
    final y = p.y - progress * p.speed;
    final opacity = p.opacity * sin(progress * pi);

    return Positioned(
      left: p.x * MediaQuery.of(context).size.width,
      top: y * MediaQuery.of(context).size.height,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0) * _iconOpacity.value,
        child: Container(
          width: p.size,
          height: p.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.brandLight.withValues(alpha: 0.5),
                blurRadius: p.size * 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double delay;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.delay,
  });
}
