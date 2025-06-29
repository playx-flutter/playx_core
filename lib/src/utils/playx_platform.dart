import 'package:flutter/foundation.dart'
    show kIsWeb, TargetPlatform, defaultTargetPlatform, kIsWasm;

/// Utility class for determining the current platform type and characteristics.
class PlayxPlatform {
  /// Returns `true` if the platform is the web.
  static bool get isWeb => kIsWeb;

  /// Returns `true` if the platform is WebAssembly.
  static bool get isWasm => kIsWasm;

  /// Returns `true` if the platform is Android.
  static bool get isAndroid =>
      !isWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Returns `true` if the platform is iOS.
  static bool get isIOS =>
      !isWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Returns `true` if the platform is macOS.
  static bool get isMacOS =>
      !isWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// Returns `true` if the platform is Windows.
  static bool get isWindows =>
      !isWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// Returns `true` if the platform is Linux.
  static bool get isLinux =>
      !isWeb && defaultTargetPlatform == TargetPlatform.linux;

  /// Returns `true` if the platform is Fuchsia.
  static bool get isFuchsia =>
      !isWeb && defaultTargetPlatform == TargetPlatform.fuchsia;

  /// Returns `true` if the platform is either Android or iOS.
  static bool get isMobile => isAndroid || isIOS;

  /// Returns `true` if the platform is either Windows, Linux, or macOS.
  static bool get isDesktop => isWindows || isLinux || isMacOS;

  /// Returns `true` if the platform is either iOS or macOS.
  static bool get isCupertino => isIOS || isMacOS;

  /// Returns `true` if the platform is either Android, web, Fuchsia, Windows, or Linux.
  static bool get isMaterial =>
      isAndroid || isWeb || isFuchsia || isWindows || isLinux;
}
