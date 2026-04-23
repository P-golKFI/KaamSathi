import 'dart:math';
import 'package:flutter/material.dart';

class CircleRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset center;
  final Color expandColor;

  CircleRevealRoute({
    required this.page,
    required this.center,
    required this.expandColor,
  }) : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, _, _) => page,
          transitionsBuilder: (ctx, animation, _, child) {
            final size = MediaQuery.of(ctx).size;
            final maxRadius =
                sqrt(size.width * size.width + size.height * size.height);
            return AnimatedBuilder(
              animation: animation,
              builder: (_, _) {
                final expandT = Curves.easeInOut
                    .transform((animation.value / 0.6).clamp(0.0, 1.0));
                final radius = expandT * maxRadius;
                final fadeT = animation.value > 0.6
                    ? Curves.easeOut.transform(
                        ((animation.value - 0.6) / 0.4).clamp(0.0, 1.0))
                    : 0.0;
                return Stack(
                  children: [
                    Opacity(opacity: fadeT, child: child),
                    if (animation.value < 1.0)
                      Opacity(
                        opacity: 1.0 - fadeT,
                        child: ClipPath(
                          clipper: _CircleRevealClipper(
                              center: center, radius: radius),
                          child: Container(
                            width: size.width,
                            height: size.height,
                            color: expandColor,
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _CircleRevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  bool shouldReclip(_CircleRevealClipper old) =>
      old.radius != radius || old.center != center;
}
