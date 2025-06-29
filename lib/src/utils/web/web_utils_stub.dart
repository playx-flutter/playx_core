import 'package:flutter/services.dart';

/// A stubbed version of [WebUtils] for non-web platforms (e.g. mobile, desktop).
///
/// All methods are safe no-ops and will not affect the app outside the web environment.
class WebUtils {
  const WebUtils._();

  /// Stub: Does nothing on non-web platforms.
  static void updateUrl(Uri uri) {}

  /// Stub: Does nothing on non-web platforms.
  static void setBodyBackgroundColor(String colorHex) {}

  /// Stub: Sets only the app switcher title, as `document.title` is not supported.
  static void setAppTitle({
    required String title,
    Color? primaryColor,
    bool webOnly = true,
  }) {
    if (webOnly) {
      return;
    }
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
          label: title, primaryColor: primaryColor?.toARGB32()),
    );
  }

  /// Stub: Always returns `false` on non-web platforms.
  static bool isFullScreen() => false;

  /// Stub: Does nothing on non-web platforms.
  static void enterFullScreen() {}

  /// Stub: Does nothing on non-web platforms.
  static void exitFullScreen() {}

  /// Stub: Does nothing on non-web platforms.
  static void toggleFullScreen() {}

  /// Stub: Does nothing on non-web platforms.
  static void reloadPage() {}

  /// Stub: Does nothing on non-web platforms.
  static void openInNewTab(String url) {}

  /// Stub: Does nothing on non-web platforms.
  static void updateQueryParameters(Map<String, String> newParams) {}
}
