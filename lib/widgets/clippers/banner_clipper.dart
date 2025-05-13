import 'package:flutter/material.dart';

class BannerShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final radius = 80.0; // Adjust this for roundness

    final path = Path();
    path.moveTo(0, 0); // top-left
    path.lineTo(size.width - radius, 0); // top-right before curve
    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      radius,
    ); // top-right curve
    path.lineTo(size.width, size.height - radius); // right side
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    ); // bottom-right curve
    path.lineTo(0, size.height); // bottom-left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
