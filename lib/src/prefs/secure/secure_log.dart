import '../../logger/playx_logger.dart';

const _tag = 'PlayxSecurePrefs';

void secureLog(String message) =>
    PlayxLogger.getLogger('PLAYX CORE')?.i(message, tag: _tag);

void secureLogError(String message, Object error, [StackTrace? stackTrace]) =>
    PlayxLogger.getLogger(
      'PLAYX CORE',
    )?.e(message, error: error, stackTrace: stackTrace, tag: _tag);
