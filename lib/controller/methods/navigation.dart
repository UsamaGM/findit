import 'package:flutter/material.dart';
import 'package:findit/controller/enums.dart';

void navigateWithSlideEffect({
  required BuildContext context,
  required Widget child,
  required AnimationDirection animationDirection,
  Curve curve = Curves.linear,
}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Offset begin;
        switch (animationDirection) {
          case AnimationDirection.ltr:
            begin = const Offset(-1, 0);
            break;
          case AnimationDirection.btt:
            begin = const Offset(0, 1);
            break;
          case AnimationDirection.ttb:
            begin = const Offset(0, -1);
            break;
          default:
            begin = const Offset(1, 0);
        }
        final tween = Tween(
          begin: begin,
          end: Offset.zero,
        ).chain(
          CurveTween(curve: curve),
        );

        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ),
  );
}
