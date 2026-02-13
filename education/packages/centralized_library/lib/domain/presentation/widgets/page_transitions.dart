import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';

/// A wrapper widget that uses GoRouter's canPop() to determine pop behavior.
/// This ensures consistent back gesture handling across all routes.
class _PopScopeWrapper extends StatelessWidget {
  final Widget child;

  const _PopScopeWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      child: child,
    );
  }
}

class PageTransitions {
  PageTransitions._();

  /// Wraps a child widget with PopScope that uses context.canPop()
  static Widget _wrapWithPopScope(Widget child) {
    return _PopScopeWrapper(child: child);
  }

  static CustomTransitionPage<T> sharedAxisHorizontal<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: _wrapWithPopScope(child),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 700),
      reverseTransitionDuration: const Duration(milliseconds: 600),
    );
  }

  /// Shared axis transition (vertical) - Material Design standard
  /// Best for: Bottom sheets, modal content
  static CustomTransitionPage<T> sharedAxisVertical<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: _wrapWithPopScope(child),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 700),
      reverseTransitionDuration: const Duration(milliseconds: 600),
    );
  }


  /// Fade through transition - Material Design standard
  /// Best for: Content replacement in same context
  static CustomTransitionPage<T> fadeThrough<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: _wrapWithPopScope(child),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 500),
    );
  }

  /// Fade scale transition - Material Design standard
  /// Best for: Dialogs, alerts, pop-ups
  static CustomTransitionPage<T> fadeScale<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: _wrapWithPopScope(child),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 500),
    );
  }

  /// Custom enhanced auth transition with multi-stage animation
  /// Combines slide, fade, and scale for premium feel
  /// Best for: Authentication flows, onboarding
  static CustomTransitionPage<T> authFlow<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: _wrapWithPopScope(child),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        );

        final scaleAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.25),
            end: Offset.zero,
          ).animate(slideAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeAnimation),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(scaleAnimation),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 850),
      reverseTransitionDuration: const Duration(milliseconds: 600),
    );
  }

  /// Custom modal slide up with backdrop
  /// Enhanced version with smooth spring physics
  /// Best for: Bottom sheets, modals with dismissible barrier
  static CustomTransitionPage<T> modalSlideUp<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
    bool barrierDismissible = true,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: _wrapWithPopScope(child),
      barrierColor: Colors.black.withValues(alpha: 0.5),
      barrierDismissible: barrierDismissible,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.3),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5),
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 650),
      reverseTransitionDuration: const Duration(milliseconds: 450),
    );
  }

  /// Alias methods for common use cases with better naming

  /// Standard forward navigation (uses shared axis horizontal)
  static CustomTransitionPage<T> forward<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) =>
      sharedAxisHorizontal(key: key, child: child, duration: duration);

  /// Detail page navigation (uses shared axis scaled)
  static CustomTransitionPage<T> detail<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) =>
      sharedAxisScaled(key: key, child: child, duration: duration);

  static CustomTransitionPage<T> sharedAxisScaled<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: _wrapWithPopScope(child),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Smooth easing curves
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubicEmphasized,
          reverseCurve: Curves.easeInOutCubic,
        );

        final curvedSecondaryAnimation = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubicEmphasized,
          reverseCurve: Curves.easeInOutCubic,
        );

        // Calculate scale values for smoother transition
        final scaleAnimation = Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).animate(curvedAnimation);

        final secondaryScaleAnimation = Tween<double>(
          begin: 1.0,
          end: 1.08,
        ).animate(curvedSecondaryAnimation);

        // Calculate opacity for smoother fade
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: ScaleTransition(
              scale: secondaryScaleAnimation,
              child: SharedAxisTransition(
                animation: curvedAnimation,
                secondaryAnimation: curvedSecondaryAnimation,
                transitionType: SharedAxisTransitionType.scaled,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                child: child,
              ),
            ),
          ),
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 450),
    );
  }
  /// Product detail page navigation (fade with subtle scale)
  static CustomTransitionPage<T> productDetail<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: _wrapWithPopScope(child),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Smooth easing curve for entrance
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        // Subtle scale for entrance (matching the sheet animation style)
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(curvedAnimation);

        // Fade animation
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        ));

        // Secondary animation for the previous page (slight scale down)
        final secondaryScaleAnimation = Tween<double>(
          begin: 1.0,
          end: 0.95,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
        ));

        return Stack(
          children: [
            // Previous page with subtle scale down
            if (secondaryAnimation.status != AnimationStatus.dismissed)
              ScaleTransition(
                scale: secondaryScaleAnimation,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            // New page with fade and scale up
            FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          ],
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
    );
  }
  /// Content replacement (uses fade through)
  static CustomTransitionPage<T> replace<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) =>
      fadeThrough(key: key, child: child, duration: duration);

  /// Modal/dialog presentation (uses fade scale)
  static CustomTransitionPage<T> modal<T>({
    required LocalKey key,
    required Widget child,
    Duration? duration,
  }) =>
      fadeScale(key: key, child: child, duration: duration);
}