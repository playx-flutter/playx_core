import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sets the status bar color and icon brightness.
///
/// [color] determines the status bar background.
/// [isDark] controls whether the status bar icons/text should be dark or light.
/// If true, icons are dark (suitable for light backgrounds).
void setStatusBarColor({
  Color color = Colors.transparent,
  bool isDark = false,
}) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: color,
      statusBarIconBrightness: isDark ? Brightness.dark : Brightness.light,
      statusBarBrightness: isDark ? Brightness.light : Brightness.dark, // for iOS
    ),
  );
}

/// Sets the navigation bar color and icon brightness (usually at the bottom).
void setNavigationBarColor({
  Color color = Colors.black,
  bool isDark = false,
}) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: color,
      systemNavigationBarIconBrightness: isDark ? Brightness.dark : Brightness.light,
    ),
  );
}


/// Locks the screen orientation.
///
/// [isPortrait] determines whether the orientation should be portrait.
/// [allowRotation] if true, enables upside-down or both landscape directions depending on [isPortrait].
///
/// Examples:
/// - Portrait only: `setOrientation()`
/// - Portrait with upside down: `setOrientation(allowRotation: true)`
/// - Landscape only: `setOrientation(isPortrait: false)`
/// - Landscape with both directions: `setOrientation(isPortrait: false, allowRotation: true)`
void setOrientation({
  bool isPortrait = true,
  bool allowRotation = false,
}) {
  final orientations = <DeviceOrientation>[];

  if (isPortrait) {
    orientations.add(DeviceOrientation.portraitUp);
    if (allowRotation) orientations.add(DeviceOrientation.portraitDown);
  } else {
    orientations.add(DeviceOrientation.landscapeLeft);
    if (allowRotation) orientations.add(DeviceOrientation.landscapeRight);
  }

  SystemChrome.setPreferredOrientations(orientations);
}

/// Hides the on-screen keyboard, if visible.
void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

/// Attempts to show the keyboard by requesting focus from the current primary focus node.
///
/// This is only useful when a widget has already requested focus and you're trying to force the system to open the keyboard.
void showKeyboard() {
  final focus = FocusManager.instance.primaryFocus;
  if (focus != null) {
    focus.requestFocus();
  }
}

/// Enables full-screen immersive mode (hides status and navigation bars).
///
/// Use this for immersive apps like video players, games, etc.
void enterFullScreen() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

/// Exits full-screen and restores system overlays (status and navigation bars).
void exitFullScreen() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

/// Copies text to clipboard.
Future<void> copyToClipboard(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
}


/// Retrieves text from clipboard.
Future<String?> getClipboardText() async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  return data?.text;
}

/// Clear the clipboard.
Future<void> clearClipboard() async {
  await Clipboard.setData(ClipboardData(text: ''));
}

