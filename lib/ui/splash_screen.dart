import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/splash_controller.dart';
import '../themes/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // timings similar to your video
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  // green glow reveal (left -> right)
  late final Animation<double> _glowReveal;

  // one-time sweep
  late final Animation<double> _sweep;

  // end breathing
  late final Animation<double> _breathe;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _logoFade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.00, 0.25, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.00, 0.35, curve: Curves.easeOutBack),
      ),
    );

    _glowReveal = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.08, 0.70, curve: Curves.easeInOut),
    );

    _sweep = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.55, 0.95, curve: Curves.easeInOut),
      ),
    );

    _breathe = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.70, 1.00, curve: Curves.easeInOut),
    );

    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.qlypCharcoal,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const _QlypBackground(),
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, __) => CustomPaint(
                    painter: _ParticlesPainter(t: _c.value),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      flex: 11,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _c,
                          builder: (_, __) {
                            return Opacity(
                              opacity: _logoFade.value,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [

                                    SizedBox(height: 130,),

                                    _AnimatedQlypLogo(
                                      assetPath: "assets/app_logo.png",
                                      width: 260,
                                      reveal: _glowReveal.value,
                                      sweep: _sweep.value,
                                      breatheT: _breathe.value,
                                    ),
                                    Opacity(
                                      opacity: _c.value > 0.8
                                          ? (_c.value - 0.8) / 0.2
                                          : 0.0,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 4.0, top: 2.0),
                                        child: Text(
                                          "",
                                          style: TextStyle(
                                            color: const Color(0xff0bd3d3),
                                            fontSize: 15,
                                            letterSpacing: 3.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Québec Local Mobility Platform",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 160,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xff0bd3d3).withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Taxi\nDelivery\nLogistics",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xff0bd3d3),
                              fontSize: 15,
                              height: 1.5,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xff0bd3d3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xff4a80f5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xff00d180),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // tagline bottom (same as your reference)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 0),
                      child: Text(
                        "v1.1.0 (Build 001)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedQlypLogo extends StatelessWidget {
  const _AnimatedQlypLogo({
    required this.assetPath,
    required this.width,
    required this.reveal,
    required this.sweep,
    required this.breatheT,
  });

  final String assetPath;
  final double width;
  final double reveal;
  final double sweep;
  final double breatheT;

  @override
  Widget build(BuildContext context) {
    final cyan = const Color(0xff63D1FF);
    final purple = const Color(0xff9F7BFF);

    final base = Image.asset(assetPath, width: width, fit: BoxFit.contain);

    final breathe = 0.10 * sin(breatheT * pi * 2);
    final glowBoost = (0.65 + (breatheT * 0.25) + breathe).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        base,

        /// 🔵 PURPLE + CYAN BLUR GLOW
        _RevealClip(
          t: reveal,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 6 + (4 * glowBoost),
              sigmaY: 6 + (4 * glowBoost),
            ),
            child: ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    cyan.withOpacity(0.9),
                    purple.withOpacity(0.9),
                  ],
                ).createShader(bounds);
              },
              child: base,
            ),
          ),
        ),

        /// ✨ SHARP COLOR GLOW
        _RevealClip(
          t: reveal,
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  cyan,
                  purple,
                ],
              ).createShader(bounds);
            },
            child: base,
          ),
        ),

        /// 🌈 LIGHT SWEEP
        Opacity(
          opacity: (reveal * 0.7).clamp(0.0, 0.7),
          child: ShaderMask(
            blendMode: BlendMode.screen,
            shaderCallback: (Rect bounds) {
              final dx = bounds.width * sweep;
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.0, 0.46, 0.54, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.08),
                  cyan.withOpacity(0.6),
                  Colors.transparent,
                ],
                transform: _SlideGradientTransform(dx: dx),
              ).createShader(bounds);
            },
            child: base,
          ),
        ),
      ],
    );
  }
}

class _RevealClip extends StatelessWidget {
  const _RevealClip({required this.t, required this.child});

  final double t; // 0..1
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clamped = t.clamp(0.0, 1.0);
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: clamped,
        child: child,
      ),
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  const _SlideGradientTransform({required this.dx});
  final double dx;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}

/// Background close to your reference splash (dark + purple glow)
class _QlypBackground extends StatelessWidget {
  const _QlypBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.0, -0.35),
          radius: 1.15,
          colors: [
            AppColors.qlypDeepNavy.withOpacity(0.55),
            AppColors.qlypDeepNavy.withOpacity(1.0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.35),
              Colors.transparent,
              Colors.black.withOpacity(0.55),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Subtle particles
class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({required this.t});
  final double t;

  static final List<_Star> _stars = _generateStars();

  static List<_Star> _generateStars() {
    final rnd = Random(24);
    return List.generate(34, (_) {
      return _Star(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        r: 0.7 + rnd.nextDouble() * 1.6,
        phase: rnd.nextDouble() * pi * 2,
        speed: 0.6 + rnd.nextDouble() * 1.1,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      final dx = s.x * size.width;
      final dy = s.y * size.height;

      final twinkle =
          0.35 + 0.65 * (0.5 + 0.5 * sin((t * 2 * pi * s.speed) + s.phase));

      final paint = Paint()
        ..color = AppColors.qlypPrimaryFreshGreen.withOpacity(0.12 * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(Offset(dx, dy), s.r, paint);

      final corePaint = Paint()
        ..color = AppColors.qlypSecondaryWarmSand.withOpacity(0.18 * twinkle);

      canvas.drawCircle(Offset(dx, dy), max(0.6, s.r * 0.45), corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.t != t;
}

class _Star {
  _Star({
    required this.x,
    required this.y,
    required this.r,
    required this.phase,
    required this.speed,
  });

  final double x;
  final double y;
  final double r;
  final double phase;
  final double speed;
}
