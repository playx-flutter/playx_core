import 'package:web/web.dart';
import 'package:flutter/services.dart';

/// A collection of static helper methods for performing common web-related tasks.
/// Only works when running on the web.
class WebUtils {
  const WebUtils._();

  /// Updates the browser's URL without navigating or reloading the page.
  ///
  /// This uses the HTML5 History API to replace the current URL in the address bar.
  static void updateUrl(Uri uri) {
    window.history.replaceState(null, '', uri.toString());
  }


  /// Sets the background color of the `<body>` element directly via inline style.
  ///
  /// This overrides any background-color set by CSS classes.
  static void setBodyBackgroundColor(String colorHex) {
    final body = document.body;
    if (body != null) {
      body.style.backgroundColor = colorHex;
    }
  }


  /// Sets the title of the web tab and application switcher.
  ///
  /// This affects browser tab titles and some OS-level application switchers.
  static void setAppTitle(String title) {
    document.title = title;
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(label: title),
    );
  }

  /// Checks if the browser is currently in fullscreen mode.
  ///
  /// Returns `true` if fullscreen mode is active, `false` otherwise.
  static bool isFullScreen() {
    return document.fullscreenElement != null;
  }

  /// Requests the browser to enter fullscreen mode.
  ///
  /// This may require a user gesture (like a button press) to succeed.
  static void enterFullScreen() {
    document.documentElement?.requestFullscreen();
  }

  /// Requests the browser to exit fullscreen mode if it's currently active.
  static void exitFullScreen() {
    document.exitFullscreen();
  }

  /// Toggles fullscreen mode: enters if not in fullscreen, exits if already in fullscreen.
  ///
  /// This is useful for toggling fullscreen with a single button or gesture.
  static void toggleFullScreen() {
    if (isFullScreen()) {
      exitFullScreen();
    } else {
      enterFullScreen();
    }
  }

  /// Reloads the current web page.
  static void reloadPage() {
    window.location.reload();
  }

  /// Opens a new browser tab or window with the given [url].
  ///
  /// Uses `target = "_blank"` by default.
  static void openInNewTab(String url) {
    window.open(url, '_blank');
  }

  /// Updates only the query parameters in the browser URL without navigating.
  ///
  /// Preserves the current path and hash.
  static void updateQueryParameters(Map<String, String> newParams) {
    final currentUri = Uri.parse(window.location.href);
    final newUri = currentUri.replace(queryParameters: newParams);
    window.history.replaceState(null, '', newUri.toString());
  }

}
