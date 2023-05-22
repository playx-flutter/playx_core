import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void setStatusBarColor(
    {Color color = Colors.transparent, bool isDark = false}) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: color,
      statusBarIconBrightness: isDark ? Brightness.dark : Brightness.light,
    ),
  );
}
