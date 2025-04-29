import 'package:flutter/material.dart';

class MyRoutes {
  static PageRouteBuilder createSlideFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide Transition: Moving from right to left
        const begin = Offset(1.0, 0.0); // Start from right
        const end = Offset.zero; // End at normal position
        const curve = Curves.easeInOut; // Smooth animation

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        // Fade Transition
        var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

        // Apply the animation: combine slide and fade
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
    );
  }
}
