import 'package:flutter/material.dart';

extension ContextColorsExtensions on BuildContext {
  /// shortcut for `Theme.of(context).primaryColor`
  Color get primaryColor => Theme.of(this).primaryColor;

  /// shortcut for `Theme.of(context).primaryColorDark`
  Color get primaryColorDark => Theme.of(this).primaryColorDark;

  /// shortcut for `Theme.of(context).primaryColorLight`
  Color get primaryColorLight => Theme.of(this).primaryColorLight;

  /// shortcut for `Theme.of(context).colorScheme.backgroundColor`
  Color get backgroundColor => Theme.of(this).colorScheme.surface;

  /// shortcut for `Theme.of(context).scaffoldBackgroundColor`
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// shortcut for `Theme.of(this).bottomAppBarTheme.color`
  Color? get bottomAppBarColor => Theme.of(this).bottomAppBarTheme.color;

  /// shortcut for `Theme.of(context).cardColor`
  Color get cardColor => Theme.of(this).cardColor;

  /// shortcut for `Theme.of(context).dividerColor`
  Color get dividerColor => Theme.of(this).dividerColor;

  /// shortcut for `Theme.of(context).disabledColor`
  Color get disabledColor => Theme.of(this).disabledColor;

  /// shortcut for `Theme.of(context).focusColor`
  Color get focusColor => Theme.of(this).focusColor;

  /// shortcut for `Theme.of(context).hoverColor`
  Color get hoverColor => Theme.of(this).hoverColor;

  /// shortcut for `Theme.of(context).highlightColor`
  Color get highlightColor => Theme.of(this).highlightColor;

  /// shortcut for `Theme.of(context).splashColor`
  Color get splashColor => Theme.of(this).splashColor;

  /// shortcut for `Theme.of(context).unselectedWidgetColor`
  Color get unselectedWidgetColor => Theme.of(this).unselectedWidgetColor;

  /// shortcut for `Theme.of(context).secondaryHeaderColor`
  Color get secondaryHeaderColor => Theme.of(this).secondaryHeaderColor;

  /// shortcut for `Theme.of(context).hintColor`

  Color get hintColor => Theme.of(this).hintColor;

  /// shortcut for `Theme.of(context).colorScheme.error`
  Color get errorColor => Theme.of(this).colorScheme.error;

  /// shortcut for `Theme.of(context).colorScheme`
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// shortcut for `Theme.of(context).colorScheme.secondary`
  Color get secondary => colorScheme.secondary;

  /// shortcut for `Theme.of(context).colorScheme.primary`
  Color get buttonPrimaryColor => colorScheme.primary;

  /// * Material 3 ColorScheme shortcuts
  
  Color get primary => colorScheme.primary;
  Color get onPrimary => colorScheme.onPrimary;
  Color get primaryContainer => colorScheme.primaryContainer;
  Color get onPrimaryContainer => colorScheme.onPrimaryContainer;

  Color get onSecondary => colorScheme.onSecondary;
  Color get secondaryContainer => colorScheme.secondaryContainer;
  Color get onSecondaryContainer => colorScheme.onSecondaryContainer;

  Color get tertiary => colorScheme.tertiary;
  Color get onTertiary => colorScheme.onTertiary;
  Color get tertiaryContainer => colorScheme.tertiaryContainer;
  Color get onTertiaryContainer => colorScheme.onTertiaryContainer;

  Color get surface => colorScheme.surface;
  Color get onSurface => colorScheme.onSurface;

  Color get error => colorScheme.error;
  Color get onError => colorScheme.onError;
  Color get errorContainer => colorScheme.errorContainer;
  Color get onErrorContainer => colorScheme.onErrorContainer;

  Color get outline => colorScheme.outline;
  Color get outlineVariant => colorScheme.outlineVariant;
  Color get shadow => colorScheme.shadow;
  Color get scrim => colorScheme.scrim;
  Color get inverseSurface => colorScheme.inverseSurface;
  Color get onInverseSurface => colorScheme.onInverseSurface;
  Color get inversePrimary => colorScheme.inversePrimary;
}
