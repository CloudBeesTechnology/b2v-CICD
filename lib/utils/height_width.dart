import 'package:flutter/material.dart';
class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }

  static double height(double inputHeight) {
    return (inputHeight / 812.0) * screenHeight; // 812 is iPhone X height
  }

  static double width(double inputWidth) {
    return (inputWidth / 375.0) * screenWidth; // 375 is iPhone X width
  }
}
