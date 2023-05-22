import 'dart:ui';

import 'package:flutter/material.dart';

///Describes how [Scrollable] widgets behave for [MaterialApp]s.
///Defaults to use touch, mouse, and trackpad.
class DefaultAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
