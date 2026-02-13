import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from top left
    path.lineTo(0, 0);

    // Draw straight down on the left side
    path.lineTo(0, size.height * 0.75);

    // Create a smooth upward curve in the center
    var controlPoint1 = Offset(size.width * 0.25, size.height * 0.85);
    var controlPoint2 = Offset(size.width * 0.75, size.height * 0.85);
    var endPoint = Offset(size.width, size.height * 0.75);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // Draw straight up on the right side
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}