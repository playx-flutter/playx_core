import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/src/utils/app_scroll_behavior.dart';

void main() {
  group('DefaultAppScrollBehavior', () {
    test('supports touch, mouse, and trackpad devices', () {
      // Arrange
      final scrollBehavior = DefaultAppScrollBehavior();

      // Act
      final dragDevices = scrollBehavior.dragDevices;

      // Assert
      expect(
        dragDevices,
        containsAll(<PointerDeviceKind>[
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        ]),
      );
    });

    test('only supports the expected devices', () {
      // Arrange
      final scrollBehavior = DefaultAppScrollBehavior();

      // Act
      final dragDevices = scrollBehavior.dragDevices;

      // Assert
      expect(dragDevices.length, 3);
      expect(dragDevices.contains(PointerDeviceKind.touch), isTrue);
      expect(dragDevices.contains(PointerDeviceKind.mouse), isTrue);
      expect(dragDevices.contains(PointerDeviceKind.trackpad), isTrue);
    });
  });
}
