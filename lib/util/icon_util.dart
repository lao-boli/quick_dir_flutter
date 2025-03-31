import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, size.height * 0.8); // 只显示80%的高度
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}

SvgPicture getIcon(String iconName,
    {double width = 24,
    double? height,
    Color color = Colors.black,
    BoxFit fit = BoxFit.contain}) {
  return SvgPicture.asset(
    'assets/icons/$iconName.svg',
    fit: fit,
    width: width,
    height: height,
    // theme: SvgTheme(currentColor: color),
    color: color,
  );
}
