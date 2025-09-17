import 'package:flutter/material.dart';

/// Кастомный переход: fade + slide + scale + background fade
class FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  final Duration duration;
  final Curve curve;

  const FadeSlidePageTransitionsBuilder({
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    final curvedSecondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: curve,
    );

    // Slide при открытии (справа → центр)
    final enterOffset = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    // Slide при закрытии (центр → влево)
    final exitOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.05, 0),
    ).animate(curvedSecondary);

    // Scale (лёгкое увеличение при входе)
    final scale = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(curvedAnimation);

    // Затемнение старой страницы
    final backgroundFade = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(curvedSecondary);

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: enterOffset,
        child: SlideTransition(
          position: exitOffset,
          child: ScaleTransition(
            scale: scale,
            child: FadeTransition(
              opacity: backgroundFade,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
