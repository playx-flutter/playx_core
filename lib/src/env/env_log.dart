import '../logger/playx_logger.dart';

/// Logs a [PlayxEnv] warning, if the playx logger is initialized.
void envLogWarning(String message) =>
    PlayxLogger.getLogger('PLAYX CORE')?.w(message, tag: 'PlayxEnv');
