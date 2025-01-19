import 'package:flutter/foundation.dart';

class PlayxLogger {
  static void _printStackTrace(
      {required String msg, bool shouldPrint = kDebugMode}) {
    final lines = msg.split('\n');
    for (var i = 0; i < lines.length; ++i) {
      final text = lines[i];
      final error = '\x1B[31m$text\x1B[0m';
      //ignore: avoid_print
      print((i >= 0 ? '║ ' : '') + error);
    }
  }

  static void printError(
      {String? header,
      String? text,
      String? stackTrace,
      bool shouldPrint = kDebugMode}) {
    if (!shouldPrint) return;
    const maxWidth = 90;
    //ignore: avoid_print
    print('');
    //ignore: avoid_print
    print('╔╣ $header');
    final error = '\x1B[31m$text\x1B[0m';
    //ignore: avoid_print
    print('║  $error');
    _printStackTrace(msg: stackTrace ?? '', shouldPrint: shouldPrint);
    //ignore: avoid_print
    print('╚${'═' * (maxWidth - 1)}╝');
  }
}
