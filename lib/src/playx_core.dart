library;

import 'package:get_it/get_it.dart';
import 'package:playx_core/src/logger/base_logger.dart';
import 'package:playx_core/src/logger/playx_logger.dart';
import 'package:worker_manager/worker_manager.dart';

import 'models/envs_settings.dart';
import 'models/prefs_settings.dart';
import 'models/secure_prefs_settings.dart';
import 'models/work_manager_settings.dart';
import 'prefs/async_prefs.dart';
import 'prefs/envs.dart';
import 'prefs/prefs.dart';
import 'prefs/prefs_with_cache.dart';
import 'prefs/secure_prefs.dart';

/// Returns the instance of `GetIt` used by the `playx_core` plugin.
///
/// This getter provides access to the `GetIt` instance that is used for
/// dependency injection within the `playx_core` plugin. It is crucial to
/// initialize `PlayxCore` by calling `bootCore` before accessing this instance.
///
/// Throws an [Exception] if `PlayxCore` has not been initialized. This indicates
/// that `bootCore` has not been called, and the `GetIt` instance is not available.
///
/// Example usage:
/// ```dart
/// // Register or retrieve services from GetIt.
/// getIt.registerSingleton<MyService>(MyService());
/// MyService myService = getIt<MyService>();
/// ```
GetIt get getIt => PlayxCore.getIt;

/// Core of the `playx_core` plugin.
///
/// This class handles the initialization and disposal of dependencies required
/// for the `playx_core` plugin. It provides a streamlined way to set up
/// essential components such as preferences, secure storage, environment
/// settings, and dependency injection management using `GetIt`. This class
/// is abstract and cannot be instantiated.
abstract class PlayxCore {
  static GetIt? _getIt;

  /// Returns the instance of `GetIt` used by the `playx_core` plugin.
  ///
  /// This getter provides access to the `GetIt` instance used for dependency
  /// injection within the `playx_core` plugin. It is essential to call
  /// `bootCore` to initialize the `GetIt` instance before accessing it.
  ///
  /// Throws an [Exception] if `PlayxCore` has not been initialized. This
  /// indicates that `bootCore` has not been called, and the `GetIt` instance
  /// is not available yet.
  ///
  /// Example usage:
  /// ```dart
  /// final getIt = PlayxCore.getIt;
  /// // Register or retrieve services from GetIt.
  /// getIt.registerSingleton<MyService>(MyService());
  /// MyService myService = getIt<MyService>();
  /// ```
  static GetIt get getIt {
    if (_getIt == null) {
      throw Exception('PlayxCore has not been initialized. '
          'Please call `bootCore` before accessing the GetIt instance.');
    }
    return _getIt!;
  }

  static PlayxBaseLogger get logger => PlayxLogger.getLogger('PLAYX CORE')!;

  /// Initializes and installs the dependencies needed for `playx_core`.
  ///
  /// This method sets up various components based on the provided parameters.
  /// It can create instances of shared preferences, secure preferences, and
  /// environment settings. The parameters allow customization of which components
  /// should be initialized.
  ///
  /// - [securePrefsSettings]: Settings to configure the secure preferences.
  ///   Defaults to an instance of `PlayxSecurePrefsSettings`.
  ///
  /// - [envSettings]: Settings for environment configuration. If provided, the
  ///   environment variables will be loaded according to the specified settings.
  ///
  /// - [prefsSettings]: Settings to configure the shared preferences. Defaults
  ///  to an instance of `PlayxPrefsSettings`.
  ///
  /// - [workerManagerSettings]: Settings to configure the worker manager. If
  ///  enabled, the worker manager will be initialized with the specified settings.
  ///
  /// Example:
  /// ```dart
  /// await PlayxCore.bootCore(
  ///   securePrefsSettings: PlayxSecurePrefsSettings(),
  ///   envSettings: PlayxEnvSettings(),
  /// );
  /// ```
  static Future<void> bootCore({
    PlayxSecurePrefsSettings securePrefsSettings =
        const PlayxSecurePrefsSettings(),
    PlayxEnvSettings? envSettings,
    PlayxPrefsSettings prefsSettings = const PlayxPrefsSettings(),
    WorkManagerSettings workerManagerSettings = const WorkManagerSettings(),
  }) async {
    PlayxLogger.initLogger(name: 'PLAYX CORE', useColoredFormatter: true);
    logger.i('Booting Preferences...');
    if (prefsSettings.createPlayxPrefs) {
      await PlayxPrefs.create();
    }
    if (prefsSettings.createPlayxAsyncPrefs) {
      await PlayxAsyncPrefs.create();
    }

    if (prefsSettings.createPlayxPrefsWithCache) {
      await PlayxPrefsWithCache.create(
          options: prefsSettings.prefsWithCacheOptions);
    }

    if (securePrefsSettings.createSecurePrefs) {
      await PlayxSecurePrefs.create(securePrefsSettings: securePrefsSettings);
    }

    logger.i('Booting Environment...');
    if (envSettings != null) {
      await PlayxEnv.load(
        fileName: envSettings.fileName,
        parser: envSettings.parser,
        mergeWith: envSettings.mergeWith,
        isOptional: envSettings.isOptional,
      );
    }

    if (workerManagerSettings.initWorkerManager) {
      await workerManager.init(
        isolatesCount: workerManagerSettings.isolatesCount,
        dynamicSpawning: workerManagerSettings.dynamicSpawning,
      );
    }

    _getIt = GetIt.instance;
    logger.i('PlayxCore initialized');
  }

  /// Disposes the resources used by `playx_core`.
  ///
  /// This method should be called when the `playx_core` resources are no longer
  /// needed, ensuring that any open resources are properly released.
  static Future<void> dispose() async {
    if (_getIt != null) {
      _getIt!.reset();
      _getIt = null;
    }
    await PlayxPrefs.dispose();
    await PlayxAsyncPrefs.dispose();
    await PlayxPrefsWithCache.dispose();
    workerManager.dispose();
  }
}
